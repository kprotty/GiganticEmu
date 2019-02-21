class CreateBadgeMappers < ActiveRecord::Migration[5.2]
  def change
    create_table :badge_mappers do |t|
      t.belongs_to :player, index: true
      t.belongs_to :badge, index: true
      t.integer :quantity
      t.timestamps
    end
  end
end
