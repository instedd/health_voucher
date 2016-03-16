require 'rails_helper'

describe BatchesController do
  before(:each) do
    @batch = Batch.make!
  end

  describe "CRUD" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, batch: {name: 'My Batch',
                              initial_serial_number: '001000',
                              quantity: '100'}
      end.to change(Batch, :count).by(1)
      new_batch = Batch.last
      expect(new_batch.name).to eq('My Batch')
      expect(new_batch.initial_serial_number).to eq('001000')
      expect(new_batch.quantity).to be(100)
    end
  end

  describe "access" do
    [:site_manager, :auditor].each do |role|
      context "for #{role}" do
        before(:each) do
          @user = User.make!(role)
          @other = User.make!
          sign_in @user
        end

        { :get => %w(index show new),
          :post => %w(create) }.each do |method, actions|
          actions.each do |action|
            describe "#{method} #{action}" do
              it "should be denied" do
                send(method, action, id: @other.id)
                response.status.should == 401
              end
            end
          end
        end
      end
    end
  end
end
