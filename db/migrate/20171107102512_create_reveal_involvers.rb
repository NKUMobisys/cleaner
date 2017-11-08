class CreateRevealInvolvers < ActiveRecord::Migration[5.0]
  def change
    create_table :reveal_involvers do |t|
      t.references :user, foreign_key: true
      t.references :reveal_history, foreign_key: true
      t.decimal :ticket

      t.timestamps
    end
  end
end
