class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :sso_id
      t.string :account
      t.string :name
      t.string :nickname
      t.string :email
      t.decimal :ticket

      t.timestamps
    end
    add_index :users, :sso_id
  end
end
