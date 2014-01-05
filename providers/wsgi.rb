include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_authorized_keys
  configure_vhost
  configure_logrotate
  configure_python
end

def configure_vhost
  r = template "/etc/nginx/sites-available/#{vhost_name}" do
    cookbook "application"
    source "site"
    owner  "root"
    group  "root"
    mode   "644"
    variables :name       => application_name,
              :root       => public_dir,
              :upstream   => nginx_upstream(connection_string),
              :domains    => application_domains.join(" "),
              :access_log => access_log,
              :error_log  => error_log,
              :aliases    => url_map
    notifies :reload, "service[nginx]"
  end
  new_resource.updated_by_last_action(true) if r.updated_by_last_action? ||
    nginx_site(vhost_name).updated_by_last_action?
end

def configure_python
  r = python_virtualenv(shared_dir.join("virtualenv").to_s) do
    owner application_username
    group application_username
    action :create
  end
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

