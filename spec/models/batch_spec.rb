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
end
