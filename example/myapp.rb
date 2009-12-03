require 'sinatra/base'
require 'haml'
require 'dirge'
require 'deja-vu' unless require ~'../lib/deja-vu'

class MyApp < Sinatra::Base

  use SoldierOfCode::DejaVu::Middleware, {:store_path => ~"/deja-vu-recordings",:cookie_name=>"a-stupid-cookie-name",:enable_record=>true}

  get '/' do
    puts "#{__FILE__}:#{__LINE__} #{__method__} HERE"
    "Hello"
  end

end
