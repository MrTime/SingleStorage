require 'spec_helper'

describe "accounts/index" do
  before(:each) do
    assign(:accounts, [
      stub_model(Account,
        :login => "Login",
        :total_size => 10
      ),
      stub_model(DropboxAccount,
        :login => "Login",
        :total_size => 10
      )
    ])
  end

  it "renders a list of accounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Login".to_s, :count => 2
    assert_select "tr>td", :text => "10".to_s, :count => 2
  end
end
