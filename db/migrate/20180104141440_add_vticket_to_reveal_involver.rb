class AddVticketToRevealInvolver < ActiveRecord::Migration[5.0]
  def change
    add_column :reveal_involvers, :vticket, :decimal
  end
end
