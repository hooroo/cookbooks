# Cookbook Name:: hooroo
# Recipe:: packages
#
# Copyright 2013, Hooroo

%w{
  htop
  screen
  unzip
}.each do |package_name|
  package package_name do
    action :install
  end
end
