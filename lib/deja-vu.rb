require ~'deja-vu/init'
require ~'rack-session-listener'
require 'digest/sha1'
require 'xampl'

module SoldierOfCode
  module DejaVu
    class Middleware

      #
      #
      #
      #
      # Possible Options:
      # ----------------------
      # 
      # :cookie_name => optional - name of the cookie to watch for and use as identifier - defaults to deja-vu
      # :enable_record => optional - (true|false)
      # :session_items => optional - [array of session keys] if present will capture
      #
      def initialize(app, opt={:enable_record=>true, :cookie_name=>'deja-vu'})
        @app = app
        @opt = opt
        @identifier = opt[:cookie_name]
      end

      def call(env)

        if @opt[:enable_record] then
          user_identifier_before = get_user_identifier(env)
          env_before = env
          t_start = Time.new
          resp = @app.call(env) # would be nice to capture all log output from the downstream as well.... TODO add log object as logger
          t_stop = Time.new
          user_identifier_after = get_user_identifier(env)

          current_request = Rack::Request.new(env)

          dejavu_recorder = nil
          if user_identifier_before != user_identifier_after then
            # something changed the identifier
            dejavu_recorder = Recorder.new(@opt)
            dejavu_recorder.identifier_change(user_identifier_after)
          end

          dejavu_recorder = Recorder.new(@opt) unless dejavu_recorder

          dejavu_recorder.record(env, resp, current_request, t_start, t_stop, user_identifier_after)

          resp
        else
          @app.call(env)
        end
      end

      #
      #
      # will use the identified cookie if available
      # otherwise will create a hash based on the env data available
      #
      def get_user_identifier(env) # => a string representing a specific browser client user
        
        http_accept = env['HTTP_ACCEPT']
        http_agent = env['HTTP_USER_AGENT']
        user_ip = env['REMOTE_ADDR']

        Rack::Request.new(env).cookies[@identifier] || Digest::SHA1.hexdigest("#{user_ip}#{http_agent}#{http_accept}")
      end

    end
  end
end
