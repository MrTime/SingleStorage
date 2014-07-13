json.files @items do |item|
  json.name item.name
  json.size item.file_size
  json.url item_path(item)
  json.thumbnail_url thumbnail_item_path(item)
  json.delete_url item_path(item)
  json.delete_type 'DELETE'
end
