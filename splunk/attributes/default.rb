# coding: utf-8

default['splunk']['version'] = '6.0.2'
default['splunk']['remote_file'] = 'splunkforwarder-6.0.2-196940-Linux-x86_64.tgz'
default['splunk']['remote_url'] = "http://www.splunk.com/page/download_track?file=#{default['splunk']['version']}/universalforwarder/linux/#{default['splunk']['remote_file']}&ac=&wget=true&name=wget&platform=Linux&architecture=x86&version=6.0&product=splunkd&typed=release&elq=463e95fc-b7b5-453d-bb81-e589d16ea93b"
