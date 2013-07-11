uri = URI.parse(ENV["REDISTOGO_URL"])
puts "-----------------------------"
puts ENV["REDISTOGO_URL"].inspect
puts "-----------------------------"
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
