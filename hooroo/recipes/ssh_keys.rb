# Cookbook Name:: hooroo
# Recipe:: ssh_keys
#
# Copyright 2013, Hooroo

require 'base64'

if node[:ssh_keys]
  node[:ssh_keys].each do |key_detail|
    authorized_keys = {}

    key_detail.each do |key_location, keys|
      next if keys.include?('layers') && (keys['layers'] & node[:opsworks][:instance][:layers]).empty?

      key_owner   = keys['owner']
      public_key  = Base64.decode64(keys['public'])
      private_key = Base64.decode64(keys['private'])

      directory File.dirname(key_location) do
        owner     key_owner
        group     'root'
        mode      "0700"
        action    :create
        recursive true
      end

      file "#{key_location}.pub" do
        owner     key_owner
        group     'root'
        mode      '0600'
        content   public_key
        action    :create
      end

      # Keep track of those keys marked to be placed into authorized_keys
      if keys.fetch('add_to_authorized_keys', false)
        authorized_keys[key_owner] ||= []
        authorized_keys[key_owner] << { public_key: public_key }
      end

      file key_location do
        owner     key_owner
        group     'root'
        mode      '0600'
        content   private_key
        action    :create
      end
    end

    # Generate authorized_keys
    authorized_keys.each_key do |owner|
      template("/home/#{owner}/.ssh/authorized_keys") do
        source  'authorized_keys.erb'
        owner   owner
        group   'root'
        mode    '0600'
        variables(
          ssh_keys: authorized_keys[owner]
        )
      end
    end
  end
end
