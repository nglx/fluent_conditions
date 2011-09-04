module FluentConditions

  def self.included(base)
    base.class_variable_set(:@@builder, Builder)

    base.class_eval do
      def is
        @@builder.new(self)
      end
    end

    base.instance_eval do
      def fluent(arg)
        builder = class_variable_get(:@@builder)

        builder.class_eval do
          define_method(arg) do
            obj = instance_variable_get(:@object)
            instance_variable_get(:@values) << obj.send(arg)
            self
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

    def true?
      @values.each do |val|
        return false unless val
      end
      true
    end

    def and
      self
    end
  end
end

