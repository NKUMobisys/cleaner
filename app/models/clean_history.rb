class CleanHistory < ApplicationRecord
  has_and_belongs_to_many :users
  has_one :reveal_history, dependent: :destroy
end
