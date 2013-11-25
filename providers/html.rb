include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_vhost
  configure_logrotate
end

def configure_vhost
  template "/etc/nginx/sites-available/#{vhost_name}" do
    cookbook "application"
    source "site"
    owner  "root"
    group  "root"
    mode   "644"
    variables
    variables :name       => application_name,
              :root       => public_dir,
              :domains    => application_domains.join(" "),
              :access_log => nginx_log,
              :error_log  => nginx_log
    notifies :reload, "service[nginx]"
  end
  nginx_site vhost_name
end

def configure_directory
  super
  [current_dir, public_dir].each do |pathname|
    r = directory pathname.to_s do
      owner application_username
      group application_username
      mode  "755"
      action :create
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end
