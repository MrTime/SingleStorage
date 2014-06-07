require 'spec_helper'

describe "items/edit" do
  before(:each) do
    @item = assign(:item, stub_model(Item,
      :name => "MyString",
      :permissions => 1,
      :parent_file_id => 1,
      :account_id => 1,
      :file_type => 1,
      :mime_type => "MyString"
    ))
  end

  it "renders the edit item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", item_path(@item), "post" do
      assert_select "input#item_name[name=?]", "item[name]"
      assert_select "input#item_permissions[name=?]", "item[permissions]"
      assert_select "input#item_parent_file_id[name=?]", "item[parent_file_id]"
      assert_select "input#item_account_id[name=?]", "item[account_id]"
      assert_select "input#item_file_type[name=?]", "item[file_type]"
      assert_select "input#item_mime_type[name=?]", "item[mime_type]"
    end
  end
end
