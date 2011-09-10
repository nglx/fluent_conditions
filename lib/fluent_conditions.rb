module FluentConditions

  def self.included(base)
    base.instance_variable_set(:@builder, Class.new(Builder))

    base.class_eval do
      def is
        self.class.instance_variable_get(:@builder).new(self, :positive)
      end

      def is_not
        self.class.instance_variable_get(:@builder).new(self, :negative)
      end
    end

    base.instance_eval do
      def fluent(*fields)
        builder = instance_variable_get(:@builder)

        fields.each do |field|
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

      def fluent_values(field, values)
        builder = instance_variable_get(:@builder)

        values.each do |value|
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
      end
    end

  end

  class Builder
    def initialize(object, type)
      @object = object
      @type = type
      @previous, @current = true, true
    end

    def or
      @or_flag = true
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
        @previous, @current = @current, field_value
      end
    end

    def end_result
      return result if @type == :positive
      return !result if @type == :negative
    end

    def result
      @previous && @current 
    end

  end
end

