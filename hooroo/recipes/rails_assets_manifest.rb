# Cookbook Name:: hooroo
# Recipe:: rails_assets_manifest
#
# Copyright 2014, Hooroo

include_recipe 'aws'
include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'hooroo::deploy_prepare'
include_recipe 'deploy::default'

node[:deploy].each do |application, deploy|

  public_directory_path = "#{deploy[:deploy_to]}/current/public"

  # Make sure the assets directory exists
  directory "#{public_directory_path}/assets" do
    owner     deploy[:user]
    group     deploy[:group]
    mode      00755
    action    :create
    recursive true
  end

  manifest_filename = "assets/manifest-#{deploy[:scm][:revision]}.json"

  aws_s3_file "#{public_directory_path}/#{manifest_filename}" do
    bucket                node[:hooroo][:rails_assets_manifest][:bucket]
    remote_path           manifest_filename
    aws_access_key_id     node[:hooroo][:rails_assets_manifest][:aws_access_key_id]
    aws_secret_access_key node[:hooroo][:rails_assets_manifest][:aws_secret_access_key]
    owner                 deploy[:user]
    group                 deploy[:group]
  end

end
