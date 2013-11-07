class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :name
      t.boolean :is_default, :default => false
      t.integer :user_id

      t.timestamps
    end
  end
end
