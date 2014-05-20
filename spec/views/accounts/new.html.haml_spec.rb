require 'spec_helper'

describe "accounts/new" do
  before(:each) do
    assign(:account, stub_model(Account,
      :login => "MyString",
      :data => "MyText"
    ).as_new_record)
  end

  it "renders new account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", accounts_path, "post" do
      assert_select "input#account_login[name=?]", "account[login]"
      assert_select "textarea#account_data[name=?]", "account[data]"
    end
  end
end
