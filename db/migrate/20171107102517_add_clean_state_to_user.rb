class AddCleanStateToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :clean_state, :integer
    User.transaction do
      User.all.each do |u|
        u.clean_state = 1
        u.save!
      end
    end
  end
end
