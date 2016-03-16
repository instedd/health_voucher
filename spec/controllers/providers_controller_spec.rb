require 'rails_helper'

describe ProvidersController do
  before(:each) do
    @clinic = Clinic.make!
    @provider = Provider.make! clinic_id: @clinic.id
  end

  context "with admin" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, provider: {clinic_id: @clinic.id,
                                 code: '1000',
                                 name: 'Joe Provider'}
      end.to change(Provider, :count).by(1)

      new_provider = Provider.last
      expect(new_provider.name).to eq('Joe Provider')
      expect(new_provider.code).to eq('1000')
      expect(new_provider.clinic).to eq(@clinic)
    end
  end

  describe "access" do
    [:site_manager, :auditor].each do |role|
      context "for #{role}" do
        before(:each) do
          @user = User.make!(role)
          sign_in @user
        end

        it "POST create should be denied" do
          expect do
            post :create, provider: {clinic_id: @clinic.id,
                                     code: '1234',
                                     name: 'Joe Provider'}
          end.to_not change(Provider, :count)
          expect(response.status).to be(401)
        end

        { :post => %w(toggle),
          :delete => %w(destroy) }.each do |method, actions|
          actions.each do |action|
            describe "#{method.upcase} #{action}" do
              it "should be denied" do
                send(method, action, id: @provider.id)
                response.status.should == 401
              end
            end
          end
        end
      end
    end
  end
end
