class RevealHistory < ApplicationRecord
  belongs_to :user
  belongs_to :clean_history
  has_many :involvers, class_name: :RevealInvolver, dependent: :destroy
end
