# This migration comes from rich (originally 20111117202133)
class AddUriCacheToRichImage < ActiveRecord::Migration[4.2]
  def change
    add_column :rich_rich_images, :uri_cache, :text
  end
end
