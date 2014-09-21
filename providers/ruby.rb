include ::Application

action :create do
  configure_user
  configure_group
  configure_directory
  configure_authorized_keys
  configure_logrotate
  configure_ruby
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

def ruby_version
  new_resource.ruby[:version] || "2.0.0-p247"
end

def gem_version
  new_resource.ruby[:rubygems] || "2.1.1"
end
