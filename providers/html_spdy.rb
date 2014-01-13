include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_authorized_keys
  configure_vhost
  configure_logrotate
end

def configure_vhost
  ssl_key_path = "/etc/nginx/#{vhost_name}.key"
  file ssl_key_path do
    content ssl_key
    owner   "root"
    group   "root"
    mode    "644"
  end

  ssl_certificate_path = "/etc/nginx/#{vhost_name}.crt"
  file ssl_certificate_path do
    content ssl_certificate
    owner   "root"
    group   "root"
    mode    "644"
  end

  template "/etc/nginx/sites-available/#{vhost_name}" do
    cookbook "application"
    source "site"
    owner  "root"
    group  "root"
    mode   "644"
    variables :name       => application_name,
              :root       => public_dir,
              :domains    => application_domains.join(" "),
              :access_log => nginx_log,
              :error_log  => nginx_log,
              :ssl        => {
                :certificate => ssl_certificate_path,
                :key         => ssl_key_path
              },
              :spdy       => true
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
