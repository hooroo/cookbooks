# coding: utf-8
#
# Cookbook Name:: splunk
# Recipe:: default
#
service "splunk" do
  supports :restart => true, :stop => true, :start => true
  action :nothing
end

bash "pre install / upgrade splunk" do
  user "root"
  code "true"
  not_if do File.exists?("/opt/splunkforwarder-#{node['splunk']['version']}") end
  notifies :stop, resources(:service => "splunk"), :immediately
end

bash "install / upgrade splunk" do
  user "root"
  code <<-EOH
    cd /tmp
    wget -c -O #{node['splunk']['remote_file']} '#{node["splunk"]["remote_url"]}'
    mkdir /opt/splunkforwarder-#{node['splunk']['version']}
    tar xzvf #{node['splunk']['remote_file']} -C /opt/splunkforwarder-#{node['splunk']['version']} --strip-components 1

    ln -nfs /opt/splunkforwarder-#{node['splunk']['version']} /opt/splunkforwarder

    /opt/splunkforwarder/bin/splunk enable boot-start --accept-license || true
    /opt/splunkforwarder/bin/splunk start --accept-license || true
  EOH
  not_if do File.exists?("/opt/splunkforwarder-#{node['splunk']['version']}") end
end

package 'python-pyrrd' do
  action :install
end

directory "/opt/splunkforwarder/etc/apps/search/bin" do
  action :create
  owner 'root'
  group 'root'
  mode 0755
end

bash "enable_splunk" do
  user "root"
  code <<-EOH
    /opt/splunkforwarder/bin/splunk enable boot-start
    /opt/splunkforwarder/bin/splunk start --accept-license
  EOH
  not_if do File.exists?('/etc/init.d/splunk') end
end

directory "/opt/splunkforwarder/etc/apps/search/local" do
  action :create
  owner 'root'
  group 'root'
  mode 0755
end

template "/opt/splunkforwarder/etc/apps/search/bin/rrd_input.sh" do
  owner 'root'
  group 'root'
  mode 0755
  source "rrd_input.sh.erb"
end

template "/opt/splunkforwarder/etc/apps/search/local/inputs.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "inputs.conf.erb"
  notifies :restart, resources(:service => "splunk"), :delayed
end

template "/opt/splunkforwarder/etc/system/local/outputs.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "outputs.conf.erb"
  notifies :restart, resources(:service => "splunk"), :delayed
end
