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

  end
end
