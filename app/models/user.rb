class User < ApplicationRecord
  has_and_belongs_to_many :clean_histories

  scope :inlab, ->{ where(study_state_id: 1) }

  def self.refresh_all_tickets
    inlab.each do |u|
      u.ticket = 5
      u.save!
    end
  end
end
