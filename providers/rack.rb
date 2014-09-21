include ::Application

action :create do
  configure_vhost
end

def configure_vhost
  variables = {
    :name       => application_name,
    :root       => public_dir,
    :upstream   => nginx_upstream(connection_string),
    :domains    => application_domains.join(" "),
    :access_log => access_log,
    :error_log  => error_log
  }

  if ssl
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

    variables[:ssl] = {
      :certificate => ssl_certificate_path,
      :key         => ssl_key_path
    }
  end

  r = template "/etc/nginx/sites-available/#{vhost_name}" do
    cookbook "application"
    source "site"
    owner  "root"
    group  "root"
    mode   "644"
    variables variables
    notifies :reload, "service[nginx]"
  end
  new_resource.updated_by_last_action(true) if r.updated_by_last_action? ||
    nginx_site(vhost_name).updated_by_last_action?
end
