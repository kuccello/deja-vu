module SoldierOfCode
  module DejaVu

    #
    # Should do the following:
    # - be configurable in
    #   - ignore/respect time between requests
    #   - ignore/call specific mime type calls (like favicon.ico etc) - css,js etc too
    #   - use webrat, curl, wget ...
    #   - turn on step through (interactive control of when requests are made)
    #   - display server log on each step or not
    #
    class Player

      attr_accessor :respect_timings, :mime_ignore, :mime_watch, :use_client, :step_through, :display_log

      def initialize(recording_pid,opts={:respect_timings=>'yes'})
        puts "#{__FILE__}:#{__LINE__} #{__method__} RECORDING PID: #{recording_pid}"
        puts "#{__FILE__}:#{__LINE__} #{__method__} #{DejaVuNS::Recording.all_recordings.size}"

        DejaVuNS::Recording.all_recordings.each do |rec|
          puts "#{__FILE__}:#{__LINE__} #{__method__} #{rec.pp_xml}"
        end

        @recording = DejaVuNS::Recording.find_by_pid(recording_pid)

        @respect_timings = ('yes' == opts[:respect_timings])
        @mime_ignore = opts[:mime_ignore] # => is an array of mime types to ignore
        @mime_watch = opts[:mime_watch] # => is an array of mime types to exeucte
        @use_client = opts[:use_client] # => what client interface to use
        @step_through = ('yes'==opts[:step_through])
        @display_log = ('yes'==opts[:display_log])

        @current_step = 0
      end

      ## TODO -- allow for enumrable play frame

      def play_frame
#        return unless @recording
        puts "#{__FILE__}:#{__LINE__} #{__method__}  #{@recording.inspect}"
        return if @current_step > @recording.record.size

        record = @recording.record[@current_step]

        resp = record.execute_as(@recording.agent)  

        @current_step += 1

        resp

      end

      def fast_forward(x=1)
        @current_step += x
      end

      def rewind(x=1)
        @current_step -= x
        @current_step = 0 if @current_step < 0
      end
    end
  end
end
