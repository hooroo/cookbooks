# Cookbook Name:: hooroo
# Recipe:: rails_restart
#
# Copyright 2014, Hooroo

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails-restart application #{application} as it is not a Rails app")
    next
  end

  node.override['opsworks']['rails_stack']['restart_command'] = "/usr/bin/monit restart unicorn_#{application}"
end
