require ~'model/init'

module SoldierOfCode
  module DejaVu
    class Analyzer

      def initialize

      end

      def overview_formatted(specific_recording_pid=nil, start_stamp=nil, end_stamp=nil)
        ovr = overview(specific_recording_pid, start_stamp, end_stamp)

        puts "==================================================================================================="
        puts " Overview: #{ovr.analysis_title}"
        puts "==================================================================================================="
        puts " Number Of Requests: #{ovr.number_of_requests}"
        puts " Number Of Errors: #{ovr.number_of_errors}"
        puts " Percentage Success: #{ovr.success_percentile}%"
        puts " Average Response Time: #{ovr.avg_response_time}"
        puts " Number Of Unique Requests: #{ovr.number_of_unique_requests}"
        puts " Number Of Unique Users: #{ovr.number_of_unique_users}"

        #:number_of_requests, :number_of_errors, :success_percentile, :analysis_title, :avg_response_time, :number_of_unique_requests, :number_of_unique_users
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

    end

    class Analysis
      attr_accessor :number_of_requests, :number_of_errors, :success_percentile, :analysis_title, :avg_response_time, :number_of_unique_requests, :number_of_unique_users

      def initialize
        @number_of_requests = 0
        @number_of_errors = 0
        @success_percentile = 1
        @analysis_title = "Untitled"
        @avg_response_time = 0.0
        @number_of_unique_requests = 0
        @number_of_unique_users = 0
        @total_request_time = 0
      end

      def add_request(rep_time)
        @number_of_requests += 1
        recalculate_succes_error_percentile
        @total_request_time += rep_time
        puts "#{__FILE__}:#{__LINE__} #{__method__} #{rep_time}"
        recalculate_avg_resp_time
      end

      def add_unique
        @number_of_unique_requests += 1
      end

      def add_user
        @number_of_unique_users += 1
      end

      def add_error
        @number_of_errors += 1
        recalculate_succes_error_percentile
      end

      def recalculate_avg_resp_time
        @avg_response_time = @total_request_time / @number_of_requests
      end

      def recalculate_succes_error_percentile
        @success_percentile = ((@number_of_requests - @number_of_errors) / @number_of_requests) * 100 if @number_of_requests > 0
        @success_percentile = 100 if @number_of_requests == 0
      end
    end
  end
end
