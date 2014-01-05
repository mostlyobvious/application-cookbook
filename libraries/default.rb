module Application

  def configure_user
    r = user application_username do
      home  application_home
      shell application_shell
      supports :manage_home => true
      action :create
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

  def configure_group
    r = group application_username do
      members application_username
      action :create
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

  def configure_directory
    [deploy_to, shared_dir, config_dir, log_dir].each do |pathname|
      r = directory pathname.to_s do
        owner application_username
        group application_username
        mode  "755"
        action :create
      end
      new_resource.updated_by_last_action(true) if r.updated_by_last_action?
    end
  end

  def configure_logrotate
    r = logrotate_app application_name do
      path log_dir
      frequency "daily"
      rotate 30
      options %w(missingok copytruncate compress)
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

  def configure_authorized_keys
    directory ssh_dir.to_s do
      owner application_username
      group application_username
      mode  "0700"
      action :create
    end

    file ssh_dir.join('authorized_keys').to_s do
      content authorized_keys.map { |entry| "#{entry.strip}\n" }.join
      owner application_username
      group application_username
      mode  "0600"
      action :create
    end
  end

  def ssh_dir
    Pathname.new(application_home).join('.ssh')
  end

  def authorized_keys
    new_resource.authorized_keys || []
  end

  def application_name
    new_resource.name
  end

  def application_username
    new_resource.username || application_name
  end

  def application_home
    new_resource.home || "/var/lib/#{application_username}"
  end

  def application_shell
    "/bin/bash"
  end

  def deploy_to
    Pathname.new(application_home)
  end

  def shared_dir
    deploy_to.join("shared")
  end

  def current_dir
    deploy_to.join("current")
  end

  def config_dir
    shared_dir.join("config")
  end

  def log_dir
    shared_dir.join("log")
  end

  def public_dir
    current_dir.join("public")
  end

  def releases_dir
    deploy_to.join("releases")
  end

  def vhost_name
    application_name
  end

  def application_domains
    [new_resource.vhost[:domain], new_resource.vhost[:aliases]].flatten.compact
  end

  def url_map
    Hash[new_resource.vhost[:url_map].map { |url, path| [url, ::File.join(application_home, path)] }]
  end

  def nginx_log
    log_dir.join("nginx.log")
  end

  def access_log
    new_resource.vhost[:access_log] || nginx_log
  end

  def error_log
    new_resource.vhost[:error_log] || nginx_log
  end

  def sockets_dir
    shared_dir.join("sockets")
  end

  def connection_string
    new_resource.vhost[:connection_string] || "unix://#{sockets_dir.join(application_name)}.sock"
  end

  def nginx_upstream(connection_string)
    case connection_string
    when /unix/
      connection_string.sub(%r{unix://}, "unix:")
    when /tcp/
      connection_string.sub(%r{tcp://}, "")
    end
  end

end


