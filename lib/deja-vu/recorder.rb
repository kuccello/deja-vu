require ~'model/init'

module SoldierOfCode
  module DejaVu
    class Recorder

#      @@writing = {} unless defined? @@writing
#
#      def self.writing?(file_name)
#        @@writing[file_name]
#      end
      attr_accessor :identifier

      def initialize(opt)
        @identifier = opt['cookie_name']
        @opt = opt
      end

      #
      #
      #
      def record(env, resp, req, start_time, end_time, identifier)

        # status, headers, body
        # resp[0], resp[1], resp[2]

        # 1. try to locate the recording
        recording = nil
        DejaVuNS.transaction do
          recording = DejaVuNS::Recording.find_by_identifier(@identifier)

#          puts "#{__FILE__}:#{__LINE__} #{__method__}  #{recording.class.name}"
          # 1.b if not found then create a new one
          unless recording
            recording = DejaVuNS.root.new_recording(DejaVuNS.pid_from_string(@identifier||identifier))
            recording.cookie = req.cookies[@identifier||identifier]
            recording.stamp = Time.new.to_i
            recording.agent = env['HTTP_USER_AGENT']
            recording.ip = env['REMOTE_ADDR']
          end

          # 2. create a new record
#          puts "#{__FILE__}:#{__LINE__} #{__method__}  #{recording.class.name}"
          record = recording.new_record("#{Time.new.to_i}")
          record.stamp = "#{Time.new.to_i}"
          record.status = "#{resp[0]}"
          record.httpmethod = env['REQUEST_METHOD']
          record.url = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
          record.request_time = ("#{end_time.to_i}.#{end_time.usec}".to_f - "#{start_time.to_i}.#{start_time.usec}".to_f).to_s

          # 3. add the body etc elements
          resp[1].each do |k, v|
            h = record.new_header
            h.name = k
            h.value = v
          end

          record.new_body().content = "<![CDATA[#{resp[2]}]]>"

          if req.post? && env['CONTENT_TYPE'] =~ %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n
            # its multipart
            # <multipart-reference name="" file-path=""/>
            # can I grab it off the env object?
            puts "#{__FILE__}:#{__LINE__} #{__method__} NOT IMPLEMENTED - MULTIPART"
          else
            # safe param recording
            req.params.each do |k,v|
              p = record.new_param()
              p.name = k
              p.value = v
            end

          end
        end

      end

      def identifier_change(new_identifier)
        DejaVuNS.transaction do
          recording = DejaVuNS::Recording.find_by_identifier(@identifier)
          if recording
            @identifier = new_identifier
            recording.cookie = new_identifier
          end
        end
      end
    end
  end
end
