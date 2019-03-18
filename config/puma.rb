require 'fileutils'

if ENV['RACK_ENV'] == 'production'
  bind 'unix:///tmp/nginx.socket'
else
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT', '3000')}"
end

before_fork do
  FileUtils.touch('/tmp/app-initialized')
end
