require 'spec_helper'

describe Batch do
  before(:each) do
    @batch = Batch.make! initial_serial_number: 100, quantity: 100
  end

  describe "validations" do
    describe "overlaps" do
      it "should validate disjoint batches" do
        @other = Batch.make initial_serial_number: 200, quantity: 100
        @other.should be_valid

        @other = Batch.make initial_serial_number: 0, quantity: 100
        @other.should be_valid
      end

      it "should reject overlaps" do
        # same batch
        @other = Batch.make initial_serial_number: 100, quantity: 100
        @other.should_not be_valid

        # bigger
        @other = Batch.make initial_serial_number: 50, quantity: 200
        @other.should_not be_valid

        # smaller
        @other = Batch.make initial_serial_number: 150, quantity: 50
        @other.should_not be_valid

        # with intersection at start
        @other = Batch.make initial_serial_number: 50, quantity: 100
        @other.should_not be_valid

        # with intersection at end
        @other = Batch.make initial_serial_number: 150, quantity: 100
        @other.should_not be_valid
      end

      it "should reject batches if last_serial_number exceeds max_serial_number" do
        @other = Batch.make initial_serial_number: 999990, quantity: 10
        @other.should be_valid

        @other.quantity = 11
        @other.should_not be_valid
      end
    end

    describe "changes after cards generated" do
      it "should validate changes to serial number and quantity if no cards were created" do
        @batch.quantity = 200
        @batch.should be_valid

        @batch.initial_serial_number = 500
        @batch.should be_valid
      end

      it "should reject changes to serial number and quantity if cards were created" do
        @card = Card.make! batch: @batch

        @batch.quantity = 200
        @batch.should_not be_valid

        @batch.reload

        @batch.initial_serial_number = 500
        @batch.should_not be_valid
      end
    end
  end

  describe "build_next" do
    it "should return a new batch using the next available serial number" do
      @new = Batch.build_next

      @new.first_serial_number.should == 200
      @new.quantity.should == Batch::DEFAULT_QUANTITY
    end

    it "should return a smaller batch if no numbers are available" do
      @other = Batch.make! initial_serial_number: 999900, quantity: 10

      @new = Batch.build_next
      @new.first_serial_number.should == 999910
      @new.quantity.should == 90
    end

    context "with the last batch reached max serial number" do
      before(:each) do
        @last_batch = Batch.make! initial_serial_number: 999990, quantity: 10
      end

      it "should return a batch with initial SN at the beginning if available" do
        @new = Batch.build_next
        @new.first_serial_number.should == 1
        @new.quantity.should == 99
      end

      it "should return a batch with initial SN at the first available spot" do
        @first_batch = Batch.make! initial_serial_number: 1, quantity: 99
        @third_batch = Batch.make! initial_serial_number: 250, quantity: 50

        @new = Batch.build_next
        @new.first_serial_number.should == 200
        @new.quantity.should == 50
      end

      it "should return a batch with 0 quantity if no spots are available" do
        @first_batch = Batch.make! initial_serial_number: 1, quantity: 99
        @third_batch = Batch.make! initial_serial_number: 200, quantity: 999999-99-100-10

        @new = Batch.build_next
        @new.quantity.should == 0
        @new.first_serial_number.should == Batch.max_serial_number + 1
      end
    end
  end
end
