class RevealHistory < ApplicationRecord
  belongs_to :user
  belongs_to :clean_history
end
