class CreateInventories < ActiveRecord::Migration[5.2]
  def change
    create_table :inventories do |t|
      t.string :name
      t.integer :gemValue
      t.integer :goldValue
      t.timestamps
    end
  end
end
