# Cookbook Name:: hooroo
# Recipe:: cron
#
# Copyright 2013, Hooroocron 

if node[:cron_entry]
  node[:cron_entry].each do |name, items|
      next if items.include?('command').nil?

      command    = items['command']
      minute     = items['minute']     || '*'
      hour       = items['hour']       || '*'
      dayofmonth = items['dayofmonth'] || '*'
      month      = items['month']      || '*'
      dayofweek  = items['dayofweek']  || '*'

      cron 'Responsys SFTP' do
        minute      "#{minute}"
        hour        "#{hour}"
        dayofmonth  "#{dayofmonth}"
        month       "#{month}"
        dayofweek   "#{dayofweek}"
        command     "#{command}"
        user        'deploy'
      end

  end
end
