require ~'model/init'
require 'patron'

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

      def initialize(recording_pid=nil, opts={:respect_timings=>'yes'})

#        @recording = DejaVuNS::Recording.find_by_pid(recording_pid)
#        @recordings = DejaVuNS::Recording.find_by_pid(recording_pid)
        @recordings = []
        unless recording_pid
          # anlyize all the recordings as a mass
          DejaVuNS::Recording.all_recordings.each do |rec|
            @recordings << rec
          end
        else
          # only analyize overview of the provided pid
          @recordings << DejaVuNS::Recording.find_by_pid(recording_pid)
        end

        @start_time = opts[:start_time]
        @end_time = opts[:end_time]
        @respect_timings = ('yes' == opts[:respect_timings])

#        @mime_ignore = opts[:mime_ignore] # => is an array of mime types to ignore
#        @mime_watch = opts[:mime_watch] # => is an array of mime types to exeucte
#        @use_client = opts[:use_client] # => what client interface to use

#        @step_through = ('yes'==opts[:step_through])
#        @display_log = ('yes'==opts[:display_log])

        @current_step = 0

        @frames = []
        build_frames
      end

      def build_frames
        @recordings.each do |rec|
          rec.record.each do |record|
            if @start_time && !@end_time && record.stamp.to_i >= @start_time # only a start stamp is provided so add all upto this date
              @frames << RequestFrame.new(rec,record)
            elsif @start_time && @end_time && record.stamp.to_i >= @start_time && record.stamp.to_i <= @end_time # start and end stamps provided (envelope of time)
              @frames << RequestFrame.new(rec,record)
            elsif !@start_time && @end_time && record.stamp.to_i <= @end_time # Just an end time provided - everthing upto this time stamp
              @frames << RequestFrame.new(rec,record)
            elsif !@start_time && !@end_time
              @frames << RequestFrame.new(rec,record)
            end
          end
        end
      end


      def play
        # plays all frames
        resps = []
        last_time_stamp = @frames.first.stamp.to_i
        @frames.each do |frame|

          resps << frame.invoke
          last_time_delta = frame.stamp.to_i - last_time_stamp
          last_time_stamp = frame.stamp.to_i
          if @respect_timings then
            puts "#{__FILE__}:#{__LINE__} #{__method__} LAST DELTA: #{last_time_delta}  --- CURRENT: #{Time.new.to_i}"
#            local_delta = last_time_delta / 1000.0
#            if local_delta > 1
#              sleep(local_delta)
#            end
            sleep(last_time_delta)
          end
        end
        puts "#{__FILE__}:#{__LINE__} #{__method__} RESPS: #{resps.inspect}"
        resps
      end


      def play_frame
        return nil unless @frames

        return if @current_step > @frames.size

        frame = @frames[@current_step]

        resp = frame.invoke

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

    class RequestFrame
      attr_accessor :url, :response, :status_code, :record, :agent

      def initialize(recording, record)
        assign_agent(recording.agent)
        @record = record
        @url = record.url
        @status_code = 0
        @response = nil
      end

      def invoke
        resp = execute_as
        @status_code = @response.status
        resp
      end

      def stamp
        @record.stamp
      end

      def httpmethod
        @record.httpmethod
      end

      def request_time
        @record.request_time
      end

      def assign_agent(agent)
        unless defined? @sess
          @sess = Patron::Session.new
          @sess.timeout = 10
          @sess.headers['User-Agent'] = agent
        end
      end

      def execute_as(agent = nil)
        assign_agent(agent) if agent

        @response = nil
        case self.httpmethod
          when 'GET'
            @response = @sess.get(self.url)
          when 'POST'
            @response = @sess.post(self.url)
          when 'PUT'
            @response = @sess.put(self.url)
          when 'DELETE'
            @response = @sess.delete(self.url)
        end

        return @response
      end

    end
  end
end

=begin
def initialize

      end


      def overview(specific_recording_pid=nil, start_stamp=nil, end_stamp=nil)

        recordings = []
        unless specific_recording_pid
          # anlyize all the recordings as a mass
          DejaVuNS::Recording.all_recordings.each do |rec|
            recordings << rec
          end
        else
          # only analyize overview of the provided pid
          recordings << DejaVuNS::Recording.find_by_pid(specific_recording_pid)
        end

        perform_overview(recordings, start_stamp, end_stamp)

      end

      def perform_overview(recordings, start_stamp=nil, end_stamp=nil)

        analysis = Analysis.new

        analysis.analysis_title = "Single User: #{recordings.first.ip}"

        records = []
        recordings.each do |rec|

          analysis.add_user

          rec.record.each do |record|
            if start_stamp && !end_stamp && record.stamp.to_i >= start_stamp # only a start stamp is provided so add all upto this date
              records << record
            elsif start_stamp && end_stamp && record.stamp.to_i >= start_stamp && record.stamp.to_i <= end_stamp # start and end stamps provided (envelope of time)
              records << record
            elsif !start_stamp && end_stamp && record.stamp.to_i <= end_stamp # Just an end time provided - everthing upto this time stamp
              records << record
            elsif !start_stamp && !end_stamp
              records << record
            end
          end
        end

        # these are vetted against the stamps
        urls_seen = []
        records.each do |record|

          analysis.add_request(record.request_time.to_f)

          unless urls_seen.include?(record.url)
            analysis.add_unique
            urls_seen << record.url
          end

          analysis.add_error if record.status.to_i >= 400

        end

        analysis
      end

=end
