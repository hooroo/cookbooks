# Cookbook Name:: hooroo
# Recipe:: rails_http_basic_auth_users
#
# Copyright 2014, Hooroo

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping hooroo::rails_http_basic_auth_users setup as this instance is not an app server")
    next
  end

  rails_http_basic_auth_users = "#{deploy[:deploy_to]}/shared/config/http_basic_auth_users.yml"

  template rails_http_basic_auth_users do
    owner deploy[:user]
    group deploy[:group]
    mode 00644
    source "rails_http_basic_auth_users.yml.erb"
    variables(
      :env     => deploy[:rails_env],
      :user_credentials => node[:hooroo][:rails_http_basic_auth_users]
    )
    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
