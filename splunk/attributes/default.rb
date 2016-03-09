# coding: utf-8

default['splunk']['version'] = '6.3.3'
default['splunk']['remote_file'] = 'splunkforwarder-6.3.3-f44afce176d0-Linux-x86_64.tgz'
default['splunk']['remote_url'] = "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=#{default['splunk']['version']}&product=universalforwarder&filename=#{default['splunk']['remote_file']}&wget=true"
