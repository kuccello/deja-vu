require 'patron'

module DejaVuNS
  class Record
=begin
<recording pid=""
             cookie=""
             stamp=""
             agent="">

    <record id=""
            stamp=""
            status=""
            httpmethod=""
            url=""
            request-time="">
=end

#    def initialize(pid)
#      super
#      assign_agent('Deja-Vu/1.0')
#    end

    def assign_agent(agent)
      unless defined? @sess
        @sess = Patron::Session.new
        @sess.timeout = 10
        @sess.headers['User-Agent'] = agent
      end
    end

    def execute_as(agent = nil)
      assign_agent(agent) if agent

      resp = nil
      case self.httpmethod
        when 'GET'
          resp = @sess.get(self.url)
        when 'POST'
          resp = @sess.post(self.url)
        when 'PUT'
          resp = @sess.put(self.url)
        when 'DELETE'
          resp = @sess.delete(self.url)
      end

      return resp

#      if resp.status < 400
#        puts resp.body
#      end
#      sess.put("/foo/baz", "some data")
#      sess.delete("/foo/baz")
#      sess.post("/foo/stuff", "some data", {"Content-Type" => "text/plain"})
    end

  end
end
