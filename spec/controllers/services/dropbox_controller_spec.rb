require 'spec_helper'

describe Services::DropboxController do

  describe "GET 'new'" do
    it "returns http redirect" do
      DropboxOAuth2Flow.any_instance.should_receive(:start).and_return('new-drop-box-path')
      get 'new'
      response.should redirect_to('new-drop-box-path')
    end
  end

  describe "GET 'auth_finish'" do
    describe 'with user approve' do
      before :each do
        DropboxOAuth2Flow.any_instance.stub(:finish).and_return(['access_token', 'user_id', 'url_state'])
        DropboxClient.any_instance.stub(:account_info).and_return('display_name' => 'name', 'quota_info' => {'quota' => 10**9})
        DropboxClient.any_instance.stub(:metadata).and_return('contents' => [{'path' => 'path1'}, {'path' => 'path2'}])
      end

      it "should create drop box account" do
        expect {
          get 'auth_finish'
        }.to change(DropboxAccount, :count).by(1)
      end

      it 'should assigns new account to @account' do
        get 'auth_finish'

        assigns(:account).should be_a(DropboxAccount)
      end

      it "redirects to the accounts" do
        get 'auth_finish'

        response.should redirect_to('/accounts')
      end
    end
  end
end
