require 'myapp'

use Rack::Session::Cookie,
    :key => 'a-stupid-cookie-name',
    :path => '/',
    :expire_after => 2592000,
    :secret => 'change_me'

run MyApp
