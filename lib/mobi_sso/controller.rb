module MobiSSO
  module Controller
    module ClassMethods

    end

    module InstanceMethods
      protected
      def authenticate_user!
        return if current_user
        unless validate_sso_login
          redirect_to new_session_url
          return
        end
        find_or_create_user
        redirect_to root_url
      end

      def find_or_create_user
        # TODO: update uinfo
        session[:user_id] = User.find_by(sso_id: params['uid']).try(:id)
        return true if session[:user_id]
        u = User.new(sso_user_info)
        u.save!
        session[:user_id] = u.id
        u
      end

      def current_user
        @current_user ||= session[:user_id] && User.find(session[:user_id])
      end

      def current_host
        @current_host ||= (request.host || Settings.server_host)
      end

      def current_server
        uri_opt = {}
        [:host, :port].each do |key|
          uri_opt[key] = request.send(key) || Settings["server_"+key.to_s]
        end
        @current_server ||= URI::HTTP.build(uri_opt).to_s
      end

      def validate_sso_login
        ["uid", "timestamp", "nonceStr", "uinfo", "token"].each do |sso_key|
          return false if params[sso_key].nil?
        end
        return false if Time.now.to_i - params["timestamp"].to_i > 30
        return false if Rails.cache.read(params["token"])

        Rails.cache.write(params["token"], true, expires_in: 10.minutes)
        params['token'] == gen_sso_token(params["timestamp"]+params["uid"]+params["nonceStr"]+Settings.sso_token+params["uinfo"])
      end

      def gen_sso_token(key)
        Digest::MD5.new.update(key).hexdigest
      end

      def sso_user_info
        JSON.parse(Base64.decode64(params["uinfo"])).merge({sso_id: params["uid"]})
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    def query_user
    end

    def query_all_user
      timestamp = Time.now.to_i.to_s
      token = gen_sso_token(current_host + timestamp + Settings.sso_token)
      sso_request = Net::HTTP.get(
        URI::HTTP.build(host: Settings.sso_host, port: (Settings.sso_port||80), path: "/api/query_all_user",
          query: {
            from: current_host,
            timestamp: timestamp,
            token: token
          }.to_query
        )
      )
      sso_request
    end



  end
end
