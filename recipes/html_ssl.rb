include_recipe "nginx::openssl_source"

node.normal["nginx"]["init_style"]     = "init"
node.normal["nginx"]["install_method"] = "source"

include_recipe "application::default"

# Example application
#
# ssl = data_bag_item("ssl", "mostlyobvious")
#
# application "mostlyobvious" do
#   provider :application_html_ssl
#   vhost :domain  => "mostlyobvio.us",
#         :aliases => ["www.mostlyobvio.us"],
#         :ssl     => {
#           :certificate => ssl["certificate"],
#           :key         => ssl["key"]
#         }
# end
