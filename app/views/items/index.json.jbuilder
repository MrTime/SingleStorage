json.array!(@items) do |item|
  json.extract! item, :id, :name, :permissions, :parent_file_id, :account_id, :file_type, :mime_type
  json.url item_url(item, format: :json)
end
