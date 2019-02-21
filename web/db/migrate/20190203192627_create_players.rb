class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.belongs_to :user, index: true
      t.string :deviceid
      t.string :gameid
      t.string :version
      t.integer :rank
      t.integer :exp
      t.text :settings
      t.timestamps
    end
  end
end
