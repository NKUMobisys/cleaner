class User::SessionController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  def new
    sso_login
  end


  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  protected

    def sso_login
      timestamp = Time.now.to_i.to_s
      token = gen_sso_token(current_host + timestamp + Settings.sso_token)
      sso_request = URI::HTTP.build(host: Settings.sso_host, port: (Settings.sso_port||80), path: "/users/sign_in",
        query: {
          from: current_server,
          timestamp: timestamp,
          token: token
        }.to_query
      )
      redirect_to sso_request.to_s
  end
end
