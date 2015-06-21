#
# Author:: Hooroo Acquire Team
# Cookbook Name:: postfix
# Recipe:: sender_dependent_relaying
#

include_recipe 'postfix'

execute 'postmap-relayhosts_map' do
  command 'postmap /etc/postfix/relayhost_map'
  action :nothing
end

email_relays = node['postfix']['email_relays'].inject({}) do |result, entry|
  result[entry['email']] = entry.fetch('relay') { node['postfix']['main']['relayhost'] }
  result
end

template '/etc/postfix/relayhost_map' do
  source 'relayhost_map.erb'
  owner 'root'
  group 'root'
  mode 0400
  notifies :run, 'execute[postmap-relayhosts_map]', :immediately
  notifies :restart, 'service[postfix]'
  variables(:email_relays => email_relays)
end

# ----------------------------------------------------------------------------------------------------------------------
# SASL passwwords
# ----------------------------------------------------------------------------------------------------------------------
execute 'postmap-relayhost_sasl_passwd' do
  command 'postmap /etc/postfix/relayhost_sasl_passwd'
  action :nothing
end

email_passwords = node['postfix']['email_relays'].inject({}) do |result, entry|
  result[entry['email']] = "#{entry['authentication']['username']}:#{entry['authentication']['password']}"
  result
end

template '/etc/postfix/relayhost_sasl_passwd' do
  source 'relayhost_sasl_passwd_map.erb'
  owner 'root'
  group 'root'
  mode 0400
  notifies :run, 'execute[postmap-relayhost_sasl_passwd]', :immediately
  notifies :restart, 'service[postfix]'
  variables(:email_passwords => email_passwords)
end
