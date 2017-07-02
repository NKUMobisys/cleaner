class CreateJoinTableUserCleanHistory < ActiveRecord::Migration[5.0]
  def change
    create_join_table :users, :clean_histories do |t|
      t.index [:user_id, :clean_history_id]
      t.index [:clean_history_id, :user_id]
    end
  end
end
