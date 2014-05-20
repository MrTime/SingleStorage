require 'spec_helper'

describe "accounts/edit" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :login => "MyString",
      :data => "MyText"
    ))
  end

  it "renders the edit account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", account_path(@account), "post" do
      assert_select "input#account_login[name=?]", "account[login]"
      assert_select "textarea#account_data[name=?]", "account[data]"
    end
  end
end
