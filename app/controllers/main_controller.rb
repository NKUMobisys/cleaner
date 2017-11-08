class MainController < ApplicationController
  before_action :set_open_time

  # TODO add lock
  def index
    judge_opening or return

    @unreveal = false
    # CleanHistory.last.destroy
    if should_gen_new_cleaner
      @unreveal = gen_new_cleaner
    else
      @clean_history = CleanHistory.last
      # p @scratch
    end

    rh = @clean_history.reveal_history
    @scratch = rh.scratch
    @revealer_name = conv_revealer_name(rh.user.name)

    @cleaners = get_current_cleaner

    @cleaner = @cleaners.first
    gen_cleaner_info

    @cleaner_info = get_cleaner_info
  end

  def waiting
  end

  def timeout
    render plain: 'Operation timeout'
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

    if ch.nil?
      render json:{status: :failed}
      return
    end

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
    def judge_opening
      if Time.current < @open_time
        render 'waiting'
        return
      end
      if opening?
        render 'wait_opening'
        return
      end

      return true
    end

    def opening?
      protect_time = 5.seconds
      ch = CleanHistory.last
      in_time = Time.now < ch.created_at + protect_time
      no_open = ch.reveal_history.scratch.nil?
      if in_time && no_open
        @remain_time = protect_time - (Time.now - ch.created_at)
        return true
      end
      false
    end

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

      seed = (Time.now.to_f * 1000).to_i # - SecureRandom.hex(1).to_i(16)
      users = []
      in_lab_users = User.cando
      loop do
        if today_is_weekend?
          break
        end

        lottery_pool = []
        min_ticket = 0x3f3f3f3f
        in_lab_users.each do |u|
          uticket = u.ticket.to_i
          min_ticket = [min_ticket, uticket].min
          User.vt(uticket).times { lottery_pool.push u }
        end
        if lottery_pool.empty?
          User.refresh_all_tickets
          break
        end

        # TODO
        # unless Date.current.monday? || Date.current.friday?
        #   (User.vt(min_ticket)/2).times { lottery_pool.push nil }
        # end

        p seed, User.vt(min_ticket)/2, lottery_pool.size

        idx = seed % lottery_pool.size
        cleaner = lottery_pool[idx]

        break if cleaner.nil?
        users << cleaner

        break
      end
      # cleaner.ticket -= 1

      ch.users = users


      ch.save!
      # cleaner.save!

      rh = RevealHistory.new
      rh.clean_history = ch
      rh.user = current_user
      rh.seed = seed
      rh.save!
      RevealHistory.transaction do
        in_lab_users.each do |u|
          rh.involvers << RevealInvolver.new(user_id: u.id, ticket: u.ticket)
        end
      end

      @clean_history = ch
      true
    end

    def get_current_cleaner
      return nil if @clean_history.nil?
      return nil if @clean_history.date < Date.current
      return @clean_history.users
    end

    def gen_cleaner_info
      @ulist = User.cando.order(:ticket)
      @awaylist = User.away

      loop do
        break
        @emoji = [""] * @ulist.size


        max_ticket = @ulist.last.ticket
        min_ticket = @ulist.first.ticket

        if max_ticket-min_ticket >= 3 && @ulist[-@ulist.size/3].ticket < max_ticket
          @ulist.each_with_index do |u, i|
            @emoji[i] = "😎" if u.ticket == max_ticket
          end
        end

        if @ulist[0].ticket < @ulist[1].ticket
          @emoji[0] = "👑"
        end
      end

      @total_tickets = 0

      User.cando.each do |u|
        @total_tickets += User.vt(u.ticket)
      end

      rh = RevealHistory.last

      @reveal_total_ticket = 0.0
      @reveal_cleaner_ticket = 0
      rh.involvers.each do |iv|
        @reveal_cleaner_ticket = User.vt(iv.ticket) if iv.user_id == @cleaner.id
        @reveal_total_ticket += User.vt(iv.ticket)
      end
      @cleaner_lucky = (@reveal_cleaner_ticket / @reveal_total_ticket *100).round(1)
    end

    def get_cleaner_info
      if @cleaners && !@cleaners.empty?
        return {type: :normal, cleaner: @cleaners}
      else
        if today_is_weekend?
          return {type: :weekend, special: "周末放假"}
        else
          return {type: :lucky, special: "大吉大利，今天休息！"}
        end
      end

      {type: :error, cleaner: nil}
    end

end
