class User < ApplicationRecord
  has_and_belongs_to_many :clean_histories

  scope :inlab, ->{ where(study_state_id: 1) }
  scope :cando, ->{ inlab.where(clean_state: 1) }
  scope :away, ->{ inlab.where(clean_state: 2) }

  def self.refresh_all_tickets
    cando.each do |u|
      u.ticket = 5
      u.save!
    end
  end

  def self.vt(ticket)
    ticket**3
  end

  def temp_away
    self.study_state_id = 2
    self.save
  end

  def back
    self.study_state_id = 1
    self.save
  end

end
