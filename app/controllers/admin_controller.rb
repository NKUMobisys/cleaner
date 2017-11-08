class AdminController < ApplicationController
  def index
    @users = User.inlab
  end

  def clean_state
    id = params['id']
    # https://gist.github.com/equivalent/3825916#gistcomment-2023132
    checked = ActiveRecord::Type::Boolean.new.cast(params['checked'])

    clean_state = if checked then 1 else 0 end
    u = User.find(id)
    u.clean_state = clean_state
    u.save
    render plain: [params['id'], params['checked']].to_json
  end

  def away_state
    id = params['id']
    # https://gist.github.com/equivalent/3825916#gistcomment-2023132
    checked = ActiveRecord::Type::Boolean.new.cast(params['checked'])

    clean_state = if checked then 2 else 1 end
    u = User.find(id)
    u.clean_state = clean_state
    u.save
    render plain: [params['id'], params['checked']].to_json
  end
end
