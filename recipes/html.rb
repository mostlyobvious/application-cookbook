include_recipe "application::default"
include_recipe "nginx"

# Example application
#
# application "mostlyobvious" do
#   provider :application_html
#   vhost :domain  => "mostlyobvio.us",
#         :aliases => ["www.mostlyobvio.us"]
# end
