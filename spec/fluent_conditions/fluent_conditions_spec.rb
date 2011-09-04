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
        @obj.is.class.should == Builder
      end

      it "should return new builder each time" do
        @obj.is.object_id.should_not == @obj.is.object_id
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

      it "should check if true" do
        @obj.admin = true
        @obj.is.admin.true?.should be_true
      end

      it "should check if false" do
        @obj.admin = false
        @obj.is.admin.true?.should be_false
      end

      it "should treat nil as false value" do
        @obj.admin = nil
        @obj.is.admin.true?.should be_false
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
          @obj.is.good.bad.true?.should be_true
        end

        it "should check two true/false conditions" do
          @obj.good = true
          @obj.bad = false
          @obj.is.good.bad.true?.should be_false
        end

        it "should check two false conditions" do
          @obj.good = false
          @obj.bad = false
          @obj.is.good.bad.true?.should be_false
        end

      end
    end

  end
end
