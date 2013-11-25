include_recipe "application::default"
include_recipe "nginx"
include_recipe "ruby-build"

# require 'open-uri'
# # Example application
# #
# application "syswise" do
#   provider :application_rack
#   vhost :domain  => "syswise.eu",
#         :aliases => ["www.syswise.eu", "calculon.syswise.eu"]
#   ruby  :version => "2.0.0-p247"
#   # authorized_keys [open('https://github.com/pawelpacana.keys').read]
# end
