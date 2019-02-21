class AddNicknameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :nickname, :string
    add_column :users, :token, :string
    add_index :users, [:token, :nickname], unique: true
  end
end
