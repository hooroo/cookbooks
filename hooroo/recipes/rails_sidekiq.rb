# Cookbook Name:: hooroo
# Recipe:: rails_sidekiq
#
# Copyright 2013, Hooroo

include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'hooroo::deploy_prepare'
include_recipe 'deploy::default'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping hooroo::rails_sidekiq setup as this instance is not an app server")
    next
  end

  sidekiq_redis_config = "#{deploy[:deploy_to]}/shared/config/sidekiq_redis_config.yml"

  template sidekiq_redis_config do
    owner deploy[:user]
    group deploy[:group]
    mode 00644
    source "sidekiq_redis_config.yml.erb"
    variables({
      :env          => deploy[:rails_env],
      :redis_url    => "redis://#{node[:rails_sidekiq][:redis_server]}:#{node[:rails_sidekiq][:redis_port]}"
    })
    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
