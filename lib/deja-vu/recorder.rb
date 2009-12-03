module SoldierOfCode
  module DejaVu
    class Recorder

      @@writing = {} unless defined? @@writing

      def self.writing?(file_name)
        @@writing[file_name]
      end


      def initialize(store_path)
        @store_path = store_path
      end

      def identifier_change(new_identifier)

      end

      def pretty_env(hash)
        pretty_hash = ""
        hash.each do |k, v|
          pretty_hash += "#{k}: #{v} --> #{v.class}\n"
        end
        pretty_hash += "\n\n"
        hash["REQUEST_PATH"].split("/").each do |r|
          pretty_hash += "#{r=="" ? "none" : r}\n"
        end
        return pretty_hash
      end

      def record_post(env, file, req)
        if req.post? then
          unless env['CONTENT_TYPE'] =~ %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n
            file.puts "=====[POST FIELDS]====="
            req.params.each do |k, v|
              file.puts "[#{k}] = [#{v}]"
            end
            file.puts "======================="
          else
            file.puts "=====[POST MULTIPART FIELDS]====="
            # TODO -- if this is a multipart post then we need to capture the files for replay later....
            file.puts "================================="
          end
        end
      end

      def record_env(env, file)
        file.puts "=====[ENV]====="
        file.puts pretty_env(env)
        file.puts "==============="
      end

      def record_session(file, session)
        file.puts "=====[SESSION]====="
        # TODO -- RECORD ONLY SPECIFIED SESSION DATA
        file.puts "==================="
      end

      def record_request(env, file)
        file.puts "METHOD: #{env['REQUEST_METHOD']}"
        file.puts "URL: #{env['rack.url_scheme']}://#{env['HTTP_HOST']}/#{env['REQUEST_URI']}"
      end

      def record_response(body, file, headers, status)
        file.puts "STATUS: #{status}"
        file.puts "HEADERS: #{headers.inspect}"
        file.puts "BODY: #{body}"
      end

      #
      #
      #
      def record(env, status, headers, body, session)

        # Open file for write (needs to be thread safe)
        while Recorder.writing?(@store_path)
          # do nothing - TODO - is this a good idea? is there a better way without using sleep(x)?
        end
        begin
          puts "#{__FILE__}:#{__LINE__} #{__method__} WRITING..."
          @@writing[@store_path] = true
          File.open(@store_path, "a") do |file|
            file.sync = true
            req = Rack::Request.new(env)

            unix_stamp = Time.new.to_i
            file.puts "REQUEST [#{unix_stamp}] START"

            record_request(env, file)
            
            # only if method post
            record_post(env, file, req)
            # THESE ONES ARE OPTIONAL & CONFIGURABLE
            record_env(env, file)
            record_response(body, file, headers, status)
            # only capture identified session information
            record_session(file, session) # TODO - FIX THIS

            file.puts "REQUEST [#{unix_stamp}] END"
            puts "#{__FILE__}:#{__LINE__} #{__method__} DONE..."
          end
        rescue => e
          puts "#{__FILE__}:#{__LINE__} #{__method__} ERROR!: #{e.backtrace}"
        ensure
          @@writing[@store_path] = false
        end

      end

    end
  end
end
