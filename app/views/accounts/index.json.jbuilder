json.array!(@accounts) do |account|
  json.extract! account, :id, :login, :data
  json.url account_url(account, format: :json)
end
