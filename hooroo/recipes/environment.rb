# Cookbook Name:: hooroo
# Recipe:: environment
#
# Copyright 2013, Hooroo

if node[:hooroo][:environment]

  template '/home/deploy/.pam_environment' do
    owner 'deploy'
    group 'www-data'
    mode 0644
    source "pam_environment.erb"
    variables({
      :environment_variables => node[:hooroo][:environment]
    })
  end

end
