class MainController < ApplicationController
  before_action :set_open_time

  def index
    if Time.current < @open_time
      render 'waiting'
      return
    end
    @revealer = false
    if should_gen_new_cleaner
      @revealer = gen_new_cleaner
    end
    @cleaners = get_current_cleaner
    @cleaner_info = get_cleaner_info
  end

  def waiting
  end

  def sync_user
    @users = JSON.parse(query_all_user).map do |uinfo|
      uinfo['sso_id'] = uinfo['id']
      uinfo.delete('id')
      uinfo.select{ |k,v| User.column_names.include? k }
    end

    @users.each do |uinfo|
      u = User.find_by(sso_id: uinfo['sso_id'])
      if u
        u.update(uinfo)
      else
        User.create!(uinfo.merge({ticket: 5}))
      end
    end

    render json: @users.to_json
  end

  protected
    def today_is_weekend?
      Date.current.saturday? || Date.current.sunday?
    end

    def set_open_time
      @open_time = Date.current.beginning_of_day + 9.hours + 30.minutes
    end

    def should_gen_new_cleaner
      return true if CleanHistory.last.nil?
      return true if CleanHistory.last.date < Date.current
    end


    def gen_new_cleaner
      ch = CleanHistory.new
      ch.date = Date.current
      seed = (Time.now.to_f * 1000).to_i

      if seed % 66 < 6
        return
      end

      if today_is_weekend?
        # return
      end

      lottery_pool = []
      User.inlab.each do |u|
        u.ticket.to_i.times { lottery_pool.push u }
      end
      if lottery_pool.empty?
        User.refresh_all_tickets
        return
      end
      lottery_pool.shuffle!

      idx = seed % lottery_pool.size
      cleaner = lottery_pool[idx]
      ch.users << cleaner
      cleaner.ticket -= 1

      ch.save!
      cleaner.save!
      true
    end

    def get_current_cleaner
      return nil if CleanHistory.last.nil?
      return nil if CleanHistory.last.date < Date.current
      return CleanHistory.last.users
    end

    def get_cleaner_info
      if @cleaners && !@cleaners.empty?
        if @cleaners.first.id == @current_user.id
          return "就是你!"
        else
          return @cleaners.first.name
        end
      else
        if today_is_weekend?
          return "周末放假"
        else
          return "大吉大利，今天休息！"
        end
      end

      "NIL"
    end

end
