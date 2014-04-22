# Cookbook Name:: hooroo
# Recipe:: sysctl_shm
#
# Copyright 2014, Hooroo


template "/etc/sysctl.d/99-hooroo-shm.conf" do
  source "sysctl_shm.erb"
  owner "root"
  group "root"
  mode 00644
  variables ({
    :shmmax => node[:shm][:max],
    :shmall => node[:shm][:all]
  })
end

# we can't use a real service because procps isn't one
execute "load-sysctls" do
  command "service procps start"
end
