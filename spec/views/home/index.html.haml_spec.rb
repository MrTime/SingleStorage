require 'spec_helper'

describe "home/index" do
  it 'renders a link to sign up' do
    render

    assert_select "a[href=?]", "/users/sign_up"
  end
end
