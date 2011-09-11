require 'spec_helper'

module FluentConditions

  describe Builder do

    describe "when module indluded" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
        end
        @obj = clazz.new
      end

      it "should provide 'is' method now" do
        @obj.should respond_to(:is)
      end

      it "should return Builder object when calling 'is'" do
        @obj.is.should be_kind_of(Builder)
      end

      it "should return new builder each time" do
        @obj.is.object_id.should_not == @obj.is.object_id
      end
    end

    describe "when included to different classes" do
      before(:each) do
        class User
          include FluentConditions
          attr_accessor :admin
          fluent :admin
        end
        @user = User.new
      end

      describe "not in hierarchy" do
        before(:each) do
          class Color
            include FluentConditions
            attr_accessor :blue
            fluent :blue
          end
          @color = Color.new
        end

        it "should provide builders of different classes" do
          @user.is.class.should_not == @color.is.class
        end

        it "should not respond to other's builder accessors" do
          @user.is.should_not respond_to(:blue)
          @color.is.should_not respond_to(:admin)
        end
      end

      describe "in hierarchy" do
        before(:each) do
          class Employee < User
            include FluentConditions
            attr_accessor :manager
            fluent :manager
          end
          @employee = Employee.new
        end

        it "should provide builders of different classes" do
          @user.is.class.should_not == @employee.is.class
        end

        it "should not respond to other's builder accessors" do
          @user.is.should_not respond_to(:manager)
          @employee.is.should_not respond_to(:admin)
        end
      end
    end

    describe "checking simple boolean conditions" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
          attr_accessor :admin
          fluent :admin
        end
        @obj = clazz.new
      end

      it "should respond to added methods" do
        @obj.is.should respond_to(:admin)
        @obj.is.should respond_to(:admin?)
        @obj.is.should respond_to(:not_admin)
        @obj.is.should respond_to(:not_admin?)
      end

      it "should check for admin user if it's admin or not" do
        @obj.admin = true
        @obj.is.admin?.should be_true
        @obj.is.not_admin?.should be_false
      end

      it "should check for non admin user if it's admin or not" do
        @obj.admin = false
        @obj.is.admin?.should be_false
        @obj.is.not_admin?.should be_true
      end

      it "should treat nil as false value" do
        @obj.admin = nil
        @obj.is.admin?.should be_false
      end

      it "should check negative condition" do
        @obj.admin = false
        @obj.is_not.admin?.should be_true
      end
    end

    describe "more than one condition" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
          attr_accessor :good, :bad
          fluent :good
          fluent :bad
        end
        @obj = clazz.new
      end

      it "should check two true conditions" do
        @obj.good = true
        @obj.bad = true
        @obj.is.good.bad?.should be_true
      end

      it "should check two true/false conditions" do
        @obj.good = true
        @obj.bad = false
        @obj.is.good.bad?.should be_false
      end

      it "should check two false conditions" do
        @obj.good = false
        @obj.bad = false
        @obj.is.good.bad?.should be_false
      end
    end

    describe "with or" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
          attr_accessor :good, :bad
          fluent :good
          fluent :bad
        end
        @obj = clazz.new
      end

      it "should check two true conditions" do
        @obj.good = true
        @obj.bad = true
        @obj.is.good.or.bad?.should be_true
      end

      it "should check two true/false conditions" do
        @obj.good = true
        @obj.bad = false
        @obj.is.good.or.bad?.should be_true
      end

      it "should check two false conditions" do
        @obj.good = false
        @obj.bad = false
        @obj.is.good.or.bad?.should be_false
      end
    end

    describe "complex conditions" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
          attr_accessor :good, :bad, :ugly
          fluent :good
          fluent :bad
          fluent :ugly
        end
        @obj = clazz.new
      end

      it "should pass them all" do
        @obj.good = true
        @obj.bad = false
        @obj.ugly = true

        @obj.is.good.bad.or.ugly?.should be_true
        @obj.is.good.or.bad.and.ugly?.should be_true
        @obj.is.good.ugly.or.bad?.should be_true

        @obj.is.bad.and.good.or.ugly?.should be_false
        @obj.is.bad.ugly.or.good?.should be_false
        @obj.is.bad.or.good.and.ugly?.should be_true

        @obj.is.ugly.or.good.and.bad?.should be_false
        @obj.is.ugly.good.and.bad?.should be_false
        @obj.is.ugly.good.or.bad?.should be_true

        @obj.is_not.good.bad.and.ugly?.should be_true
      end
    end

    describe "when values were defined" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
          attr_accessor :color
          fluent :color, :values => [:red, :green]
        end
        @product = clazz.new
      end

      it "should respond to accesor methods" do
        @product.is.should respond_to(:red)
        @product.is.should respond_to(:green)
        @product.is.should respond_to(:not_red)
        @product.is.should respond_to(:not_green)

        @product.is.should respond_to(:red?)
        @product.is.should respond_to(:green?)
        @product.is.should respond_to(:not_red?)
        @product.is.should respond_to(:not_green?)
      end

      it "should check condition by value" do
        @product.color = :red

        @product.is.red?.should be_true
        @product.is.green?.should be_false
        @product.is.red.and.green?.should be_false
        @product.is.red.or.green?.should be_true

        @product.is.not_red?.should be_false
        @product.is.not_green?.should be_true
      end
    end
  end

end
