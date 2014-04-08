include ::Application
include ::Application::SSL

action :create do
  configure_user
  configure_group
  configure_directory
  configure_authorized_keys
  configure_vhost
  configure_logrotate
end

def configure_vhost
  configure_ssl_vhost
end
