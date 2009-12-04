require ~'generated_model/DejaVuNS'

module DejaVuNS
  Xampl.set_default_persister_kind(:filesystem)
  Xampl.set_default_persister_format(:xml_format)

  def self.persistence_type
    Xampl.default_persister_kind
  end

  def self.root
    root = nil
    DejaVuNS.transaction do
      root = DejaVu['recordings']

      unless root

        root = DejaVu.lookup('recordings')

        unless root

          root = DejaVu.new('recordings') do | it |
            #it.setup_defaults
          end
        end
      end
    end
    root
  end

  def self.transaction
    result = nil
    Xampl.transaction('recordings') do
      result = yield
    end
    result
  end

  def self.pid_from_string(string)
    string.downcase.gsub(/[ \/\\:\?'"%!@#\$\^&\*\(\)\+]/, '')
  end
end
