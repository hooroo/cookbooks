# Cookbook Name:: hooroo
# Recipe:: ssh_keys
#
# Copyright 2013, Hooroo

require 'base64'

if node[:ssh_keys]
  node[:ssh_keys].each do |key_detail|

    key_detail.each do |key_location, keys|

      next if keys.include?('layers') && (keys['layers'] & node[:opsworks][:instance][:layers]).empty?

      public_key = Base64.decode64(keys['public'])
      private_key = Base64.decode64(keys['private'])

      # ensure the resting place exists
      directory File.dirname(key_location) do
        owner     keys['owner']
        group     'root'
        mode      "0700"
        action    :create
        recursive true
      end

      file "#{key_location}.pub" do
        owner     keys['owner']
        group     'root'
        mode      '0600'
        content   public_key
        action    :create
      end

      file key_location do
        owner     keys['owner']
        group     'root'
        mode      '0600'
        content   private_key
        action    :create
      end

    end
  end
end
