#!/bin/bash

DATE=`cat /tmp/inventory | awk -F = '/DATE/{print $2}'`
exec > /ansible/output/inforcollect_result_$DATE\.csv

echo "IP,hostname,release,kernel_version,all_ip,load_average,run_level,tmout,selinux_status,selinux_config,services,time_zone,LANG,HISTTIMEFORMAT,PASS_MAX_DAYS,PASS_MIN_DAYS,PASS_WARN_AGE,umask,HISTSIZE,uid0,ntp_package,ntp_status,ntp_server,usb_disable,ctl_alt_del,inode,file_system,journal_status,total_process,total_threads,openfile_numbers,memall,memfree,swapall,swapfree,tcp_port_listenning,tcp6_port_listenning,device,pv_name,pv_size,vg_name,vg_size,lv_name,lv_size,route,fstab,mtab,user,group,limits,"

for i in `ls /ansible/output/`
do 
  grep "^$i" /tmp/inventory &> /dev/null
  if [ $? -ne 0 ]; then
    continue
  fi
  echo -e "$i,\c"
  for j in {Hostname,release,kernel_version,all_ip,load_average,run_level,tmout,selinux_status,selinux_config,services,time_zone,LANG,HISTTIMEFORMAT,PASS_MAX_DAYS,PASS_MIN_DAYS,PASS_WARN_AGE,umask,HISTSIZE,uid0,ntp_package,ntp_status,ntp_server,usb_disable,ctl_alt_del,inode,file_system,journal_status,total_process,total_threads,openfile_numbers,memall,memfree,swapall,swapfree,tcp_port_listenning,tcp6_port_listenning,device,pv_name,pv_size,vg_name,vg_size,lv_name,lv_size,Route,fstab,mtab,user,group,limits,}
  do
      echo -e "`grep ^$j /ansible/output/$i/inforcollect_$DATE |awk -F: '{print $2}'`,\c"
  done
  echo
done


