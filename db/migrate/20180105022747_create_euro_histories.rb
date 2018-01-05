class CreateEuroHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :euro_histories do |t|
      t.references :reveal_history, foreign_key: true

      t.timestamps
    end

    EuroHistory.new(reveal_history_id: 105).save!
  end
end
