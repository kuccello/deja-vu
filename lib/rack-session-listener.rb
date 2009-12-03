
require 'rack/session/abstract/id'
require 'thread'

module Rack
  module Session
    module Abstract
      class ID

        def context(env, app=@app)
          load_session(env)
          status, headers, body = app.call(env)

          begin
            # call Deja Vu to record
            dejavu = env['soldierofcode.dejavu.recorder']
            dejavu.record(env,status,headers,body,self) if dejavu
          rescue => e
            # obviously and error
            puts "#{__FILE__}:#{__LINE__} #{__method__} #{e.backtrace}"
          end

          commit_session(env, status, headers, body)
        end
        
      end
    end
  end
end
