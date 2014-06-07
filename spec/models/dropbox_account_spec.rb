require 'spec_helper'

describe DropboxAccount do
  before :each do
    DropboxClient.any_instance.should_receive(:account_info).and_return('display_name' => 'name', 'quota_info' => {'quota' => 10**9})
  end

  let(:account) { DropboxAccount.create! access_token: 'access_token' }

  it 'extract account name' do
    account.login.should eq('name')
  end

  it 'extract account quota size' do
    account.total_size.should eq(10**9)
  end
end
