#
# Author:: Hooroo Acquire Team
# Cookbook Name:: postfix
# Recipe:: relayhost_map
#

include_recipe 'postfix'

execute 'postmap-relayhosts_map' do
  command 'postmap /etc/postfix/sasl_passwd'
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
