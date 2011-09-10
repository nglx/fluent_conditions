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
              current_value = instance_variable_get(:@object).send(field)
              add_boolean(current_value)
              self
            end

            define_method("#{field}?") do
              current_value = instance_variable_get(:@object).send(field)
              add_boolean(current_value)
              calculate_result
            end

            define_method("not_#{field}") do
              current_value = !instance_variable_get(:@object).send(field)
              add_boolean(current_value)
              self
            end

            define_method("not_#{field}?") do
              current_value = !instance_variable_get(:@object).send(field)
              add_boolean(current_value)
              calculate_result
            end
          end
        end
      end
    end

  end

  class Builder
    def initialize(object, type)
      @object = object
      @values = []
      @type = type
    end

    def or
      @or_flag = true
      self
    end

    def and
      self
    end

    private

    def add_boolean(current_value)
      if @or_flag
        @values[-1] = @values.last || current_value
        @or_flag = false
      else
        @values << current_value
      end
    end

    def calculate_result
      return true? if @type == :positive
      return false? if @type == :negative
    end

    def true?
      @values.each do |val|
        return false unless val
      end
      true
    end

    def false?
      not true?
    end

  end
end

