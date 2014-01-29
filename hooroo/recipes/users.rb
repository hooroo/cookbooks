# Cookbook Name:: hooroo
# Recipe:: users
#
# Copyright 2013, Hooroo

# Add all SSH users to the www-data group
#
node[:ssh_users].each do |user|

  ssh_user_id, ssh_user = user

  group node[:nginx][:user] do
    action :modify
    append true
    members ssh_user['name']
  end
end
