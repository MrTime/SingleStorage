json.files @items do |item|
  json.name item.name
  json.size item.file_size
  json.url item_path(item)
  json.thumbnailUrl thumbnail_item_path(item)
  json.deleteUrl item_path(item)
  json.deleteType 'DELETE'
end
