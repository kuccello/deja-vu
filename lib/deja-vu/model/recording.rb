=begin
<recording pid=""
             cookie=""
             stamp=""
             agent="">

    <record id=""
            stamp=""
            status=""
            method=""
            url=""
            request-time="">

      <header name="" value=""/>

      <body><![CDATA[HTML OR WHATEVER HERE]]></body>

      <param name="" value=""/>

      <multipart-reference name="" file-path=""/>

    </record>

  </recording>
=end
module DejaVuNS
  class Recording

    def self.find_by_identifier(ident)
      DejaVuNS.root.recording.each do |rec|
        return rec if rec.cookie == ident
      end
      nil
    end

    def self.find_by_pid(pid)
      rec = nil
      DejaVuNS.transaction do
        rec = DejaVuNS.root.recording[pid]
      end
      rec
    end

    def self.all_recordings
      recordings = []
      DejaVuNS.transaction do
        DejaVuNS.root.recording.each do |rec|
          recordings << rec
        end
      end
      recordings
    end

  end
end
