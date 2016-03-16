require 'rails_helper'

describe StatementsController do
  before(:each) do
    @stmt = Statement.make!
  end

  describe "access" do
    context "for auditor" do
      before(:each) do
        @user = User.make!(:auditor)
        sign_in @user
      end

      it "GET index should be allowed" do
        get :index
        response.status.should == 200
      end

      it "GET show should be allowed" do
        get :index, id: @stmt.id
        response.status.should == 200
      end

      it "POST export should be allowed" do
        post :export, stmt_ids: "#{@stmt.id}"
        response.status.should == 200
      end

      { :get => %w(generate),
        :post => %w(toggle_status do_generate),
        :delete => %w(destroy) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, id: @stmt.id)
              response.status.should == 401
            end
          end
        end
      end 
    end

    context "for site manager" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      { :get => %w(index show generate),
        :post => %w(toggle_status do_generate export),
        :delete => %w(destroy) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, id: @stmt.id)
              response.status.should == 401
            end
          end
        end
      end 
    end
  end
end

