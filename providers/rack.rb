include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_vhost
  configure_logrotate
  configure_ruby
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
              :error_log  => error_log
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
  r = ruby_build(application_name) do
    version  ruby_version
    rubygems gem_version
    home     application_home
    owner    application_username
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

def configure_authorized_keys
  # FIXME
  #   public_keys username do
  #  home home_dir
  # end
end

def ruby_version
  new_resource.ruby[:version] || "2.0.0-p247"
end

def gem_version
  new_resource.ruby[:rubygems] || "2.1.1"
end

