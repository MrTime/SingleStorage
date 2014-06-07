require 'spec_helper'

describe DropboxAccount do
  before :each do
    DropboxClient.any_instance.stub(:account_info).and_return('display_name' => 'name', 'quota_info' => {'quota' => 10**9})
    DropboxClient.any_instance.stub(:metadata).and_return('contents' => [{'path' => 'path1'}, {'path' => 'path2'}])
  end

  let(:account) { DropboxAccount.create! access_token: 'access_token' }

  it 'extract account name' do
    account.login.should eq('name')
  end

  it 'extract account quota size' do
    account.total_size.should eq(10**9)
  end

  it 'extract files from dropbox folder' do
    account.items.count.should eq(2)
  end

  it 'extract file name from dropbox folder' do
    DropboxClient.any_instance.should_receive(:metadata).and_return('contents' => [{'path' => 'path1'}])
    account.items.first.name.should eq("path1")
  end

  it 'extract file from dropbox folder' do
    DropboxClient.any_instance.should_receive(:metadata).and_return('contents' => [{'path' => 'path1', 'is_dir' => false}])
    account.items.first.file?.should be_true
  end

  it 'extract folder from dropbox folder' do
    DropboxClient.any_instance.should_receive(:metadata).and_return('contents' => [{'path' => 'path1', 'is_dir' => true}])
    account.items.last.directory?.should be_true
  end
end
