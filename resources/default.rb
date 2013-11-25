actions :create

def initialize(*args)
  super
  @action = :create
end

attribute :home,      :kind_of => String
# attribute :logrotate, :kind_of => Hash
# attribute :env,       :kind_of => Hash
# attribute :shell,     :kind_of => String
attribute :username,  :kind_of => String
attribute :vhost,     :kind_of => Hash
attribute :ruby,      :kind_of => Hash
attribute :python,    :kind_of => Hash
# attribute :authorized_keys, :kind_of => Array
