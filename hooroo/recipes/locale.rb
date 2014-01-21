# Cookbook Name:: hooroo
# Recipe:: locale
#
# Copyright 2013, Hooroo

bash "Generate locales" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    locale-gen en_AU.UTF-8
  EOH
  not_if "test -f /var/lib/belocs/list"
end
