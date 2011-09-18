require 'spec_helper'

module FluentConditions

  describe FluentConditions do

    describe "when module indluded" do
      before(:each) do
        clazz = Class.new do
          include FluentConditions
        end
        @obj = clazz.new
      end

      it "should provide 'fluent' method now" do
        @obj.class.should respond_to(:fluent)
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

  end
end
