class AddStudyStateToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :study_state_id, :integer
    add_index :users, :study_state_id
  end
end
