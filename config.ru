require 'bundler/setup'
Bundler.require

require 'rack/rewrite'



use Rack::Rewrite do
  r301 %r{.*}, 'http://latter.3months.com$&', :if => Proc.new {|rack_env|
    rack_env['SERVER_NAME'] != 'latter.3months.com'
  }
end

require File.join(File.dirname(__FILE__), 'latter')
run Latter
