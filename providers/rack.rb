include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_authorized_keys
  configure_vhost
  configure_logrotate
  configure_ruby
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

def configure_directory
  super
  [releases_dir, sockets_dir].each do |pathname|
    r = directory pathname.to_s do
      owner application_username
      group application_username
      mode  "755"
      action :create
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end

def configure_ruby
  p = self
  r = ruby(application_name) do
    version  p.ruby_version
    rubygems p.gem_version
    home     p.application_home
    owner    p.application_username
  end
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

def configure_deployment
  # FIXME
  # template "#{examples_dir}/deploy.rb" do
  #   owner username
  #   group username
  #   mode 0644
  #   source "deploy.rb.erb"
  #   variables :name => name, :deploy_to => deploy_to, :username => username, :ruby_version => node["ruby"]
  # end
end

def ruby_version
  new_resource.ruby[:version] || "2.0.0-p247"
end

def gem_version
  new_resource.ruby[:rubygems] || "2.1.1"
end


