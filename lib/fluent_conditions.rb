module FluentConditions

  def self.included(base)
    base.class_variable_set(:@@builder, Builder)

    base.class_eval do
      def is
        @@builder.new(self, :positive)
      end

      def is_not
        @@builder.new(self, :negative)
      end
    end

    base.instance_eval do
      def fluent(field)
        builder = class_variable_get(:@@builder)

        builder.class_eval do
          define_method(field) do
            add_boolean(field)
            self
          end

          define_method("#{field}?") do
            add_boolean(field)
            calculate
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

    def add_boolean(field)
      if @or_flag
        @values[-1] = @values.last || @object.send(field)
        @or_flag = false
      else
        @values << @object.send(field)
      end
    end

    def calculate
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

