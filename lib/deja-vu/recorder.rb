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

        @foo = Time.new.to_i
      end

      def export(to_file_named)
        # TODO -- IMPLEMENT THIS
      end

      #
      #
      #
      def record(env, resp, req, start_time, end_time, identifier)

        # status, headers, body
        # resp[0], resp[1], resp[2]

        # 1. try to locate the recording
        recording = nil

        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} INSIDE RECORD - STARTING TXN"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

        DejaVuNS.transaction do
puts "#{__FILE__}:#{__LINE__} #{Thread.current} JUST INSIDE"
          recording = DejaVuNS::Recording.find_by_identifier(@identifier)
puts "#{__FILE__}:#{__LINE__} #{Thread.current} RECORDING FOUND: #{recording.pid}"
#          puts "#{__FILE__}:#{__LINE__} #{Thread.current}  #{recording.class.name}"
          # 1.b if not found then create a new one
          unless recording
puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
            recording = DejaVuNS.root.new_recording(DejaVuNS.pid_from_string(@identifier||identifier))
            recording.cookie = req.cookies[@identifier||identifier]
            recording.stamp = Time.new.to_i
            recording.agent = env['HTTP_USER_AGENT']
            recording.ip = env['REMOTE_ADDR']
puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          end

          # 2. create a new record
#          puts "#{__FILE__}:#{__LINE__} #{Thread.current}  #{recording.class.name}"
puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          record = recording.new_record("#{Time.new.to_i}")
puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          record.stamp = "#{Time.new.to_i}"
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "

          record.status = "#{resp[0]}"
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          record.httpmethod = env['REQUEST_METHOD']
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          record.url = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
          record.request_time = ("#{end_time.to_i}.#{end_time.usec}".to_f - "#{start_time.to_i}.#{start_time.usec}".to_f).to_s
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "

          # 3. add the body etc elements
          resp[1].each do |k, v|
            h = record.new_header
            h.name = k
            h.value = v
          end
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "

          record.new_body().content = "<![CDATA[#{resp[2]}]]>"
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} "

          if req.post? && env['CONTENT_TYPE'] =~ %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n
            # its multipart
            # <multipart-reference name="" file-path=""/>
            # can I grab it off the env object?
            puts "#{__FILE__}:#{__LINE__} #{Thread.current} NOT IMPLEMENTED - MULTIPART"
          else
            puts "#{__FILE__}:#{__LINE__} #{Thread.current} "
            # safe param recording
            req.params.each do |k,v|
              p = record.new_param()
              p.name = k
              p.value = v
            end
            puts "#{__FILE__}:#{__LINE__} #{Thread.current} "

          end
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} ABOUT TO PRINT XML"
          STDOUT.flush
#          puts "#{__FILE__}:#{__LINE__} #{Thread.current} #{recording.pp_xml}"
        end

        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} DONE TXN"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts "#{__FILE__}:#{__LINE__} #{Thread.current} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

      end

      def identifier_change(new_identifier)
        DejaVuNS.transaction do
          puts "#{__FILE__}:#{__LINE__} #{Thread.current} IDENTIFIER CHANGE"
          recording = DejaVuNS::Recording.find_by_identifier(@identifier)
          if recording
            puts "#{__FILE__}:#{__LINE__} #{Thread.current} IDENTIFIER CHANGE HERE"
            @identifier = new_identifier
            recording.cookie = new_identifier
            puts "#{__FILE__}:#{__LINE__} #{Thread.currentta} IDENTIFIER CHANGE HERE #{recording.cookie}"
          end
        end
      end
    end
  end
end
