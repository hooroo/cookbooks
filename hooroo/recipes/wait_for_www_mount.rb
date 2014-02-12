# Cookbook Name:: hooroo
# Recipe:: wait_for_www_mount
#
# Copyright 2013, Hooroo

bash "wait for touch /srv/www/.delete-me" do
  user "root"
  code <<-EOS
    for i in `seq 60`
    do
      date=`date`
      result=`touch /srv/www/.delete-me > /dev/null 2>&1; echo $?`
      echo "${date} try=[${i}] result=[${result}]"

      if [ ${result} -eq 0 ]; then
        # Directory is now mounted, let's continue
        exit 0
      fi

      sleep 1
    done

    # Directory not mounted, let's NOT continue
    exit 1
  EOS
end.run_action(:run)
