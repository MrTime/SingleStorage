require 'spec_helper'

describe "items/index" do
  before(:each) do
    assign(:items, [
      stub_model(Item,
        :name => "Name",
        :permissions => 1,
        :parent_file_id => 2,
        :account_id => 3,
        :file_type => 4,
        :mime_type => "Mime Type"
      ),
      stub_model(Item,
        :name => "Name",
        :permissions => 1,
        :parent_file_id => 2,
        :account_id => 3,
        :file_type => 4,
        :mime_type => "Mime Type"
      )
    ])
  end

  it "renders a list of items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Mime Type".to_s, :count => 2
  end
end
