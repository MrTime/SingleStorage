# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    name "MyString"
    permissions 1
    parent_file_id 1
    account_id 1
    file_type 1
    mime_type "MyString"
  end
end
