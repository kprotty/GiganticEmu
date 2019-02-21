class CreateInventoryMappers < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_mappers do |t|
      t.belongs_to :player, index: true
      t.belongs_to :inventory, index: true
      t.integer :quantity
      t.timestamps
    end
  end
end
