module FluentConditions

  def self.included(base)
    base.instance_variable_set(:@builder, Class.new(Builder))

    base.class_eval do
      include InstanceMethods
    end

    base.extend ClassMethods
  end

  module InstanceMethods
    def is
      self.class.instance_variable_get(:@builder).new(self, :positive)
    end

    def is_not
      self.class.instance_variable_get(:@builder).new(self, :negative)
    end
  end

  module ClassMethods
    def fluent(field, options = {})
      builder = instance_variable_get(:@builder)

      if options.include?(:values)
        options[:values].each do |value|
          builder.class_eval do
            define_method(value) do
              update_and_continue(instance_variable_get(:@object).send(field) == value)
            end

            define_method("#{value}?") do
              update_and_finish(instance_variable_get(:@object).send(field) == value)
            end

            define_method("not_#{value}") do
              update_and_continue(instance_variable_get(:@object).send(field) != value)
            end

            define_method("not_#{value}?") do
              update_and_finish(instance_variable_get(:@object).send(field) != value)
            end
          end
        end
      elsif options.include?(:if)
        field_name = options[:as]
        condition_check = options[:if]

        builder.class_eval do
          define_method(field_name) do
            update_and_continue(condition_check.call(instance_variable_get(:@object).send(field)))
          end

          define_method("#{field_name}?") do
            update_and_finish(condition_check.call(instance_variable_get(:@object).send(field)))
          end

          define_method("not_#{field_name}") do
            update_and_continue(!condition_check.call(instance_variable_get(:@object).send(field)))
          end

          define_method("not_#{field_name}?") do
            update_and_finish(!condition_check.call(instance_variable_get(:@object).send(field)))
          end
        end
      else 
        builder.class_eval do
          define_method(field) do
            update_and_continue(instance_variable_get(:@object).send(field))
          end

          define_method("#{field}?") do
            update_and_finish(instance_variable_get(:@object).send(field))
          end

          define_method("not_#{field}") do
            update_and_continue(!instance_variable_get(:@object).send(field))
          end

          define_method("not_#{field}?") do
            update_and_finish(!instance_variable_get(:@object).send(field))
          end
        end
      end
    end
  end


  class Builder
    def initialize(object, type)
      @object = object
      @type = type
      @previous, @current, @big_or = true, true, false
    end

    def or
      @or_flag = true
      self
    end

    def OR
      @big_or = @big_or || result
      @big_or_flag = true
      @previous, @current = true, true
      self
    end

    def and
      self
    end

    private

    def update_and_continue(field_value)
      update_result(field_value)
      self
    end

    def update_and_finish(field_value)
      update_result(field_value)
      end_result
    end

    def update_result(field_value)
      if @or_flag
        @current = @current || field_value
        @or_flag = false
      else
        @previous, @current = @previous && @current, field_value
      end
    end

    def end_result
      if @big_or_flag
        return (@big_or || result) if @type == :positive
        return !(@big_or || result) if @type == :negative
      end
      return result if @type == :positive
      return !result if @type == :negative
    end

    def result
      @previous && @current 
    end

  end
end

