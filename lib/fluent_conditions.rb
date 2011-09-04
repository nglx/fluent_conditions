module FluentConditions

  def self.included(base)
    base.class_variable_set(:@@builder, Builder)

    base.class_eval do
      def is
        @@builder.new(self)
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
            true?
          end
        end
      end
    end

  end

  class Builder
    def initialize(object)
      @object = object
      @values = []
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

    def true?
      @values.each do |val|
        return false unless val
      end
      true
    end

  end
end

