name             'application'
maintainer       'Syswise'
maintainer_email 'pawel.pacana@syswise.eu'
license          'MIT'
description      'Installs/Configures application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends          'nginx'
depends          'ruby-build'
depends          'logrotate'