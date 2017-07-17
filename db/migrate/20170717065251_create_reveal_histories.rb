class CreateRevealHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :reveal_histories do |t|
      t.references :user, foreign_key: true
      t.integer :seed, limit: 8
      t.text :scratch
      t.references :clean_history, foreign_key: true

      t.timestamps
    end
  end
end
