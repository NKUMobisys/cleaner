class User < ApplicationRecord
  has_and_belongs_to_many :clean_histories

  scope :inlab, ->{ where(study_state_id: 1) }
end
