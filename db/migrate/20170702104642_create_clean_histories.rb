class CreateCleanHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :clean_histories do |t|
      t.date :date
      t.string :comment

      t.timestamps
    end
  end
end
