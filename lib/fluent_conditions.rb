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
              field_value = instance_variable_get(:@object).send(field)
              add_boolean(field_value)
              self
            end

            define_method("#{field}?") do
              field_value = instance_variable_get(:@object).send(field)
              add_boolean(field_value)
              end_result
            end

            define_method("not_#{field}") do
              field_value = !instance_variable_get(:@object).send(field)
              add_boolean(field_value)
              self
            end

            define_method("not_#{field}?") do
              field_value = !instance_variable_get(:@object).send(field)
              add_boolean(field_value)
              end_result
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

    def add_boolean(field_value)
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

