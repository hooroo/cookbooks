# Cookbook Name:: hooroo
# Recipe:: cron
#
# Copyright 2013, Hooroocron 

if node[:cron_entry]
  node[:cron_entry].each do |name, items|
      next if items.include?('command').nil?
      next if items.include?('layers') && (items['layers'] & node[:opsworks][:instance][:layers]).empty?

      command = items['command']
      minute  = items['minute']  || '*'
      hour    = items['hour']    || '*'
      day     = items['day']     || '*'
      month   = items['month']   || '*'
      weekday = items['weekday'] || '*'

      cron "#{name}" do
        minute  "#{minute}"
        hour    "#{hour}"
        day     "#{day}"
        month   "#{month}"
        weekday "#{weekday}"
        command "#{command}"
        user    'deploy'
      end

  end
end
