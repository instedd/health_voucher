require 'spec_helper'

describe BatchesController do
  before(:each) do
    @batch = Batch.make!
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
