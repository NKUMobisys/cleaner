class EuroHistory < ApplicationRecord
  belongs_to :reveal_history
  
  def users
    reveal_history.clean_history.users
  end
end
