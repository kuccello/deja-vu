require ~'deja-vu/init'
require ~'rack-session-listener'
require 'digest/sha1'

module SoldierOfCode
  module DejaVu
    class Middleware

      #
      #
      #
      #
      # Possible Options:
      # ----------------------
      # :store_path => required - location on disk where to store the recordings
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
          resp = @app.call(env) # would be nice to capture all log output from the downstream as well.... TODO
          # TODO -- maybe integrate SPY vs SPY here to identify other browser details? maybe not as agent data could be parsed later...
          user_identifier_after = get_user_identifier(env)

          current_request = Rack::Request.new(env)

          dejavu_recorder = nil
          if user_identifier_before != user_identifier_after then
            # something changed the identifier
            dejavu_recorder = Recorder.new("#{@opt[:store_path]}/#{user_identifier_before}.session")
            dejavu_recorder.identifier_change(user_identifier_after)
          end

          dejavu_recorder = Recorder.new("#{@opt[:store_path]}/#{user_identifier_after}.session") unless dejavu_recorder


          dejavu_recorder.record(env, resp[0], resp[1], resp[2], env['rack.session'])

#          dejavu_recorder = env['soldierofcode.dejavu.recorder']
#          unless dejavu_recorder
#            dejavu_recorder = Recorder.new("#{@opt[:store_path]}/#{user_identifier}.session")
#            env['soldierofcode.dejavu.recorder'] = dejavu_recorder
#          end

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
