require 'sinatra/base'

class RackEnvWatch < Sinatra::Base

  

  def pretty_env(hash)
    pretty_hash = ""
    hash.each do |k, v|
      pretty_hash += "#{k}: #{v} --> #{v.class}<br />"
    end
    pretty_hash += "<br /><br />"
    hash["REQUEST_PATH"].split("/").each do |r|
      pretty_hash += "#{r=="" ? "none" : r}<br />"
    end
    return pretty_hash
  end


  get '*' do
    pretty_env(request.env)
  end

end
