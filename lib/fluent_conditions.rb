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
            or_flag = instance_variable_get(:@or_flag)
            values = instance_variable_get(:@values)

            if or_flag
              values[-1] = values.last || obj.send(arg)
              instance_variable_set(:@or_flag, false)
            else
              values << obj.send(arg)
            end

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

    def or
      @or_flag = true
      self
    end

    def and
      self
    end
  end
end

