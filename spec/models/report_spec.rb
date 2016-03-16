require 'rails_helper'

describe Report do
  describe "group_by" do
    class A < Report
      group_by :a, :b
    end

    class B < Report
    end

    it "defines the default value as the first given option" do
      A.new.by.should == :a
    end

    it "defines predicates for each option" do
      A.new.should respond_to(:by_a?)
      A.new.should respond_to(:by_b?)
    end

    it "understands strings for the value" do
      A.new(by: 'b').by.should == :b
    end

    it "ignores invalid values and defaults to the first option" do
      A.new(by: 'foo').should be_by_a
    end

    it "is optional" do
      lambda do B.new end.should_not raise_error
      B.new.by.should be_nil
    end
  end
end

