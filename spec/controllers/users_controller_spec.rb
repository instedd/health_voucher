require 'spec_helper'

describe UsersController do
  context "with admin" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, user: {email: 'user@example.com',
                             password: 'secret',
                             password_confirmation: 'secret',
                             role: 'auditor'}
      end.to change(User, :count).by(1)

      new_user = User.last
      expect(new_user.email).to eq('user@example.com')
      expect(new_user).to be_auditor
    end

    it "PATCH update" do
      subject = User.make!
      patch :update, id: subject.id, user: {email: 'user@example.com',
                                            password: 'secret',
                                            password_confirmation: 'secret',
                                            role: 'auditor'}
      expect(response).to be_redirect
      subject = subject.reload
      expect(subject.email).to eq('user@example.com')
      expect(subject).to be_auditor
    end

    it "update doesn't change the role" do
      patch :update, id: @user.id, user: {email: @user.email,
                                          role: 'site_manager'}
      subject = User.find(@user.id)
      expect(subject).to be_admin
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

        { :get => %w(index new edit),
          :put => %w(update),
          :post => %w(create),
          :delete => %w(destroy) }.each do |method, actions|
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

