module ItemsHelper
  def item_icon(item, size='xs')
    if item.thumbnail_exists?
      image_tag thumbnail_item_path(item, s: size)
    else
      image_tag "items/#{item.icon}.gif"
    end
  end
end
