class MainController < ApplicationController
  before_action :set_open_time

  def index
    if Time.current < @open_time
      render 'waiting'
      return
    end
    @unreveal = false

    if should_gen_new_cleaner
      @unreveal = gen_new_cleaner
    else
      @clean_history = CleanHistory.last

      rh = @clean_history.reveal_history
      @scratch = rh.scratch
      @revealer_name = conv_revealer_name(rh.user.name)
      # p @scratch
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

  def lucky_card
    ch_id = params['clean_history']
    ch = CleanHistory.find_by(id: ch_id)
    rh = ch.reveal_history
    if rh.user != current_user
      render json: {}, status: :forbidden
      return
    end

    ActiveRecord::Base.transaction do
      if rh.scratch.nil?
        cleaner = rh.clean_history.users.first
        cleaner.ticket -= 1
        cleaner.save!
      end

      rh.scratch = params["scratch"]
      rh.save!
    end

    render json: {status: :ok}
  end

  protected
    def today_is_weekend?
      Date.current.saturday? || Date.current.sunday?
    end

    def set_open_time
      @open_time = Date.current.beginning_of_day + 9.hours + 30.minutes
    end

    def should_gen_new_cleaner
      ch = CleanHistory.last
      return true if ch.nil?
      return true if ch.date < Date.current

      if !ch.users.empty? && ch.reveal_history&.scratch.nil?
        ch.destroy
        return true
      end
      false
    end

    def conv_cleaner_name(name)
      if name==@current_user.name
        return '就是你'
      end
      name
    end

    def conv_revealer_name(name)
      if name==@clean_history.users.first&.name
        return '自摸'
      end
      name
    end

    def gen_new_cleaner
      ch = CleanHistory.new
      ch.date = Date.current
      seed = (Time.now.to_f * 1000).to_i - SecureRandom.hex(1).to_i(16)


      if today_is_weekend?
        return
      end

      if Date.current.monday? || !(seed%66 < 6)
        lottery_pool = []
        User.inlab.each do |u|
          uticket = u.ticket.to_i
          (uticket**3).times { lottery_pool.push u }
        end
        if lottery_pool.empty?
          User.refresh_all_tickets
          return
        end

        p seed, lottery_pool.size

        idx = seed % lottery_pool.size
        cleaner = lottery_pool[idx]
        ch.users << cleaner
      end
      # cleaner.ticket -= 1



      ch.save!
      # cleaner.save!

      rh = RevealHistory.new
      rh.clean_history = ch
      rh.user = current_user
      rh.seed = seed
      rh.save!

      @clean_history = ch
      true
    end

    def get_current_cleaner
      return nil if @clean_history.nil?
      return nil if @clean_history.date < Date.current
      return @clean_history.users
    end

    def get_cleaner_info
      if @cleaners && !@cleaners.empty?
        return {type: :normal, cleaner: conv_cleaner_name(@cleaners.first.name)}
      else
        if today_is_weekend?
          return {type: :weekend, cleaner: "周末放假"}
        else
          return {type: :lucky, cleaner: "大吉大利，今天休息！"}
        end
      end

      {type: :error, cleaner: "error"}
    end

end
