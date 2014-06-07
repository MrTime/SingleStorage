require 'spec_helper'

describe "accounts/new" do
  before(:each) do
    assign(:account, stub_model(Account,
      :login => "MyString",
      :data => "MyText"
    ).as_new_record)
  end

  it "renders link to dropbox" do
    render

    assert_select "a.new-dropbox", href: '/services/dropbox/new'
  end
end
