#!/bin/bash

health_check_datadir="/tmp/rhel-inforcollect"
language=$LANG
unset LANG LC_ALL
export LANG=en_US.UTF-8
export LC_ALL=$LANG
os_version=$(cat /etc/redhat-release |awk '{print $7}'|cut -d\. -f1)

exec > $health_check_datadir

echo "########################### tmout #############################"
echo 'echo $TMOUT'
echo -e "tmout:\c"
echo $TMOUT
echo -e "\n"

echo "########################### load average #############################"
echo "uptime |awk -F: '{print\$(NF)}'|sed 's/,//g'"
echo -e "load_average:\c"
uptime |awk -F: '{print$(NF)}'|sed 's/,//g'
echo -e "\n"

echo "########################### release #############################"
echo awk '{print $7}' /etc/redhat-release
echo -e "release :\c"
awk '{print $7}' /etc/redhat-release
echo -e "\n"

echo "########################### kernel_version #############################"
echo "uname -a|awk '{print \$3}'"
echo -e "kernel_version :\c"
uname -a|awk '{print $3}'
echo -e "\n"

echo "########################### all_ip #############################"
echo "/sbin/ip a|grep \"inet \"|grep -v \"127.0\"|awk '{print $2}'|awk -F/ '{print\$1}'|xargs"
echo -e "all_ip :\c"
/sbin/ip a|grep "inet "|grep -v "127.0"|awk '{print $2}'|awk -F/ '{print$1}'|xargs
echo -e "\n"

echo "########################### hostname #############################"
echo "hostname"
echo -e "Hostname :\c"
hostname
echo -e "\n"

echo "########################### run_level #############################"
echo "who -r|awk '{print \$2}'"
echo -e "run_level:\c"
who -r|awk '{print $2}'
echo -e "\n"

echo "######################### Selinux status ##########################"
echo "/usr/sbin/getenforce"
echo -e "selinux_status:\c"
/usr/sbin/getenforce
echo -e "\n"

echo "######################### Selinux config ##########################"
echo "egrep -v  \"^#|^$\" /etc/selinux/config|xargs"
echo -e "selinux_config:\c"
egrep -v  "^#|^$" /etc/selinux/config|xargs
echo -e "\n"

echo "######################### Service status ##########################"
[ "$os_version" == "7" ] && echo "systemctl list-unit-files |grep enabled|egrep \"bluetooth|postfix|cups|acpid|sendmail\" |awk '{print \$1}'|xargs"
[ "$os_version" == "5" ]||[ "$os_version" == "6" ]&& echo "/sbin/chkconfig --list|egrep \"$runlevel:on\"|egrep \"bluetooth|postfix|cups|acpid|sendmail\"|awk '{print \$1}'|xargs"
echo -e "services:\c"
if [ "$os_version" == "7" ]; then
     systemctl list-unit-files |grep enabled|egrep "bluetooth|postfix|cups|acpid|sendmail" |awk '{print $1}'|xargs
else
    runlevel=$(/sbin/runlevel |awk '{print $2}') 
    /sbin/chkconfig --list|egrep "$runlevel:on"|egrep "bluetooth|postfix|cups|acpid|sendmail"|awk '{print $1}'|xargs
fi
echo -e "\n"

echo "######################### Time zone ###############################"
echo "date -R|awk '{print \$6}'"
echo -e "time_zone:\c"
date -R|awk '{print $6}'
echo -e "\n"

echo "###################### System language ###########################"
echo "echo \$LANG"
echo -e "LANG:\c"
echo $language
echo -e "\n"

echo "################### History command format #######################"
echo "echo \$HISTTIMEFORMAT"
echo -e "HISTTIMEFORMAT:\c"
echo $HISTTIMEFORMAT
echo -e "\n"

echo "####################### login.defs ###############################"
echo ''
echo "grep ^PASS_MAX_DAYS /etc/login.defs |awk  '{print\$2}'"
echo "^PASS_MIN_DAYS /etc/login.defs |awk  '{print\$2}'"
echo "^PASS_WARN_AGE /etc/login.defs |awk  '{print\$2}'"
echo -e "PASS_MAX_DAYS:\c"
grep ^PASS_MAX_DAYS /etc/login.defs |awk  '{print$2}'
echo -e "PASS_MIN_DAYS:\c"
grep ^PASS_MIN_DAYS /etc/login.defs |awk  '{print$2}'
echo -e "PASS_WARN_AGE:\c"
grep ^PASS_WARN_AGE /etc/login.defs |awk  '{print$2}'
echo -e "\n"

echo "######################## profile #################################"
echo "grep umask /etc/profile|tail -2 |awk '{print \$2}'|xargs"
echo "echo \$HISTSIZE"
echo -e "umask:\c"
grep umask /etc/profile|tail -2 |awk '{print $2}'|xargs
echo -e "HISTSIZE:\c"
echo $HISTSIZE
#grep -v ^# /etc/profile |grep -v ^$
echo -e "\n"

echo "###################### user's UID=0 ##############################"
echo "awk -F: '\$3 == 0 && \$1 != "root" { print \$1 }' /etc/passwd|xargs"
echo -e "uid0:\c"
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd|xargs
echo -e "\n"

echo "###################### system-auth ###############################"
echo "grep -v ^# /etc/pam.d/system-auth|grep -v ^$|xargs"
echo -e "system_auth:\c"
grep -v ^# /etc/pam.d/system-auth|grep -v ^$|xargs
echo -e "\n"

echo "###################### limits.conf ###############################"
echo "ulimit -a|sed 's/(.*)//g'|xargs"
echo -e "limits:\c"
ulimit -a|sed 's/(.*)//g'|xargs
echo -e "\n"

echo "################### File permissions #############################"
[ "$os_version" == "7" ] && echo "ls -l /etc/crontab /etc/securetty /boot/grub2/grub.cfg /etc/hosts.allow /etc/hosts.deny /etc/inittab /etc/login.defs /etc/profile /etc/bashrc|xargs"
[ "$os_version" == "5" ]||[ "$os_version" == "6" ]&& echo "ls -l /etc/crontab /etc/securetty /boot/grub/grub.conf /etc/hosts.allow /etc/hosts.deny /etc/inittab /etc/login.defs /etc/profile /etc/bashrc|xargs"
echo -e "file_permissions:\c"
if [ "$os_version" == "7" ]; then
    ls -l /etc/crontab /etc/securetty /boot/grub2/grub.cfg /etc/hosts.allow /etc/hosts.deny /etc/inittab /etc/login.defs /etc/profile /etc/bashrc|xargs
else
    ls -l /etc/crontab /etc/securetty /boot/grub/grub.conf /etc/hosts.allow /etc/hosts.deny /etc/inittab /etc/login.defs /etc/profile /etc/bashrc|xargs

fi
echo -e "\n"

echo "######################### NTP ####################################"
[ "$os_version" == "7" ] && echo "rpm -qa chrony";echo "systemctl status chronyd|grep Active|awk '{print \$2}'";echo "grep ^server /etc/chrony.conf|xargs"
[ "$os_version" == "5" ] || [ "$os_version" == "6" ] && echo "rpm -qa ntp"&&echo "/sbin/service ntpd status|awk '{print \$NF}'"&&echo "grep ^server /etc/ntp.conf|xargs"
if [ "$os_version" == "7" ]; then
    echo -e "ntp_package:\c"
    rpm -qa chrony
    echo -e "ntp_status:\c"
    systemctl status chronyd|grep Active|awk '{print $2}'
    #systemctl status chronyd.service
    echo -e "ntp_server:\c"
    grep ^server /etc/chrony.conf|xargs 
else
    echo -e "ntp_package:\c"
    rpm -qa ntp
    echo -e "ntp_status:\c"
    /sbin/service ntpd status|awk '{print $NF}'
    echo -e "ntp_server:\c"
    grep ^server /etc/ntp.conf|xargs
fi
echo -e "\n"

echo "################### Kernel parameters ############################"
[ "$os_version" == "7" ]&&echo "grep -v ^# /usr/lib/sysctl.d/*.conf /etc/sysctl.d/*.conf|awk -F: '{print \$2}'|grep -v ^\$|xargs"&&echo "grep -v ^# /usr/lib/sysctl.d/*.conf /etc/sysctl.d/*.conf|awk -F: '{print \$2}'|grep -v ^$"
[ "$os_version" == "5" ]||[ "$os_version" == "6" ] && echo "grep -v ^# /etc/sysctl.conf|grep -v ^\$"
echo -e "kernel_parameters:\c"
if [ "$os_version" == "7" ]; then
    grep -v ^# /usr/lib/sysctl.d/*.conf /etc/sysctl.d/*.conf|awk -F: '{print $2}'|grep -v ^$|xargs
    echo -e "\n"
    grep -v ^# /usr/lib/sysctl.d/*.conf /etc/sysctl.d/*.conf|awk -F: '{print $2}'|grep -v ^$
else
    grep -v ^# /etc/sysctl.conf|grep -v ^$
fi
echo -e "\n"

echo "################## disable usb devices ###########################"
echo "grep \"install usb-storage /bin/true\" /etc/modprobe.d/*"
echo -e "usb_disable:\c"
grep "install usb-storage /bin/true" /etc/modprobe.d/*
if [ $? -eq 0 ]; then
  echo disabled 
else
  echo not disabled
fi
echo -e "\n"

echo "############### disable Control+Alt+Delete #######################"
[ "$os_version" == "7" ] && echo "ls -l /etc/systemd/system/ctrl-alt-del.target"
[ "$os_version" == "6" ] && echo "grep \"^start on control-alt-delete\" /etc/init/control-alt-delete.conf \&\> /dev/null"
[ "$os_version" == "5" ] && echo "grep \"^ca::ctrlaltdel\" /etc/inittab \&\> /dev/null"
echo -e "ctl_alt_del:\c"
if [ "$os_version" == "7" ]; then
    ls -l /etc/systemd/system/ctrl-alt-del.target
    if [ $? -eq 0 ];then
       echo disabled
    else
       echo not disabled
    fi
elif [ "$os_version" == "6" ]; then
    grep "^start on control-alt-delete" /etc/init/control-alt-delete.conf &> /dev/null
    if [ $? -eq 0 ];then
       echo not disabled
    else
       echo disabled
    fi
elif [ "$os_version" == "5" ]; then
    grep "^ca::ctrlaltdel" /etc/inittab &> /dev/null
    if [ $? -eq 0 ];then
       echo not disabled
    else
       echo disabled
    fi
fi
echo -e "\n"

echo "##################### journal services ###########################"
[ "$os_version" == "7" ] && echo "systemctl status rsyslog|grep Active|awk '{print \$2}'"
[ "$os_version" == "6" ] && echo "/sbin/service rsyslog status|awk '{print \$(NF-0)}'"
[ "$os_version" == "5" ] && echo "/sbin/service syslog status|head -1|awk '{print \$(NF-0)}'"
if [ "$os_version" == "7" ]; then
    echo -e "journal_status:\c"
    systemctl status rsyslog|grep Active|awk '{print $2}'
    #systemctl status rsyslog
elif [ "$os_version" == "6" ]; then
    echo -e "journal_status:\c"
    /sbin/service rsyslog status|awk '{print $(NF-0)}'
    #service rsyslog status
elif [ "$os_version" == "5" ]; then
    echo -e "journal_status:\c"
    /sbin/service syslog status|head -1|awk '{print $(NF-0)}'
    #service syslog status
fi
echo -e "\n"

echo '###################### error&warn log  ###########################'
#egrep -i "warn|error" /var/log/messages
echo -e "\n"

echo "######################## sshd_config #############################"
echo "grep -v ^# /etc/ssh/sshd_config |grep -v ^$|xargs"
echo -e "sshd_config:\c"
grep -v ^# /etc/ssh/sshd_config |grep -v ^$|xargs
echo -e "\n"

echo "############# Top 10 process of  CPU useage ######################"
echo "ps aux|sort -k3rn|head|xargs"
echo -e 'cpu_top10$\c'
ps aux|sort -k3rn|head|xargs
echo -e "\n"

echo "############# Top 10 process of  MEM useage ######################"
echo "ps aux|sort -k4rn|head|xargs"
echo -e 'mem_top10$\c'
ps aux|sort -k4rn|head|xargs
echo -e "\n"

echo "######################### inode useage ###########################"
echo "df -Pih|egrep ^/|xargs"
echo -e "inode:\c"
df -Pih|egrep ^/|xargs
df -Pih|egrep ^/
echo -e "\n"

echo "################ file system disk space usage ####################"
echo "df -PTh|egrep ^/|xargs"
echo -e "file_system:\c"
df -PTh|egrep ^/|xargs
df -PTh|egrep ^/
echo -e "\n"

echo "##################### process total numbers ######################"
echo "ps aux|wc -l"
echo -e "total_process:\c"
ps aux|wc -l
echo -e "\n"

echo "##################### threads total numbers ######################"
echo "ps -efL|wc -l"
echo -e "total_threads:\c"
ps -efL|wc -l
echo -e "\n"

echo "##################### open files total numbers ###################"
echo "lsof |wc -l"
echo -e "openfile_numbers:\c"
which lsof &> /dev/null
if [ $? -eq 0 ];then
    lsof -n |wc -l
else
    echo "lsof not installed"
fi
echo -e "\n"

echo "######################### memory usage  ##########################"
echo "free"
echo -e "memall:\c"
echo `free -g|egrep Mem|awk '{print$2}'`G
#echo -e "`/usr/sbin/dmidecode -t memory | grep "Size:"|egrep "MB|GB"|awk '{print $2}'|awk '{a=a+$1}END{print a}'`\c"
#echo `/usr/sbin/dmidecode -t memory | grep "Size:"|egrep "MB|GB"|awk '{print $3}'`
echo -e "memfree:\c"
echo `free -g|egrep Mem|awk '{print$4}'`G
echo -e "swapall:\c"
echo `free -g|egrep Swap|awk '{print$2}'`G
echo -e "swapfree:\c"
echo `free -g|egrep Swap|awk '{print$4}'`G
free -g
echo -e "\n"

echo "######################## port listening ##########################"
echo "netstat -ntlp"
echo -e "tcp_port_listenning:\c"
echo -e "`netstat -ntlp|grep "tcp "|awk '{print$4}'|awk -F: '{print$2}'|xargs` \c"
netstat -ntlp|grep "tcp "|awk -F/ '{print $2}'|xargs|sed 's/://g'
echo -e "tcp6_port_listenning:\c"
echo -e "`netstat -ntlp|grep "tcp6"|awk '{print$4}'|awk -F: '{print$4}'|xargs` \c"
netstat -ntlp|grep "tcp6"|awk -F/ '{print $2}'|xargs
echo -e "\n"

echo "############################ iostat ##############################"
echo "iostat -d -x -k 1 5"
which iostat &> /dev/null
if [ $? -eq 0 ];then
    iostat -d -x -k 1 5
else
    echo "sysstat not installed"
fi
echo -e "\n"

echo "############################## lvs ###############################"
echo "lvs"
echo -e "lvs:\c"
lvs|tail -2|xargs
echo -e "\n"

echo "############################## device ###############################"
echo "egrep -v \"[0-9]$|name|^\$\" /proc/partitions |awk '{print\$4}'|xargs"
echo -e "device:\c"
egrep -v "[0-9]$|name|^$" /proc/partitions |awk '{print$4}'|xargs
#which lsblk &> /dev/null
#if [ $? -eq 0 ];then
#  lsblk|egrep ^[a-z]|egrep -v "sr|loop"|awk '{print$1}'|xargs
#else
#  echo lsblk not install
#fi
echo -e "\n"

echo "########################### pvdisplay ############################"
echo "pvdisplay"
echo -e "pv_name:\c"
if [ "$os_version" == "6" ]; then
  /sbin/pvdisplay |grep -i "PV Name"|awk '{print$3}'|xargs
else
  /usr/sbin/pvdisplay |grep -i "PV Name"|awk '{print$3}'|xargs
fi
echo -e "pv_size:\c"
if [ "$os_version" == "6" ]; then
  /sbin/pvdisplay |grep -i "PV Size"|awk '{print $3,$4}'|xargs
else
  /usr/sbin/pvdisplay |grep -i "PV Size"|awk '{print $3,$4}'|xargs
/usr/sbin/pvdisplay
fi
echo -e "\n"

echo "########################### vgdisplay ############################"
echo "vgdisplay"
echo -e "vg_name:\c"
if [ "$os_version" == "6" ]; then
  /sbin/vgdisplay |grep -i "VG Name"|awk '{print$3}'|xargs
else
  /usr/sbin/vgdisplay |grep -i "VG Name"|awk '{print$3}'|xargs
fi
echo -e "vg_size:\c"
if [ "$os_version" == "6" ]; then
  /sbin/vgdisplay |grep -i "VG Size"|awk '{print $3,$4}'|xargs
  /sbin/vgdisplay
else
  /usr/sbin/vgdisplay |grep -i "VG Size"|awk '{print $3,$4}'|xargs
  /usr/sbin/vgdisplay
fi
echo -e "\n"

echo "########################### lvdisplay ############################"
echo "lvdisplay"
echo -e "lv_name:\c"
if [ "$os_version" == "6" ]; then
  /sbin/lvdisplay |grep -i "LV Name"|awk '{print$3}'|xargs
else
  /usr/sbin/lvdisplay |grep -i "LV Name"|awk '{print$3}'|xargs
fi
echo -e "lv_size:\c"
if [ "$os_version" == "6" ]; then
  /sbin/lvdisplay |grep -i "LV Size"|awk '{print $3,$4}'|xargs
  /sbin/lvdisplay
else
  /usr/sbin/lvdisplay |grep -i "LV Size"|awk '{print $3,$4}'|xargs
  /usr/sbin/lvdisplay
fi
echo -e "\n"

echo "####################### route information ########################"
echo "route -n"
echo -e "Route:\c"
/sbin/route -n|grep ^[0-9]|xargs
/sbin/route -n|grep ^[0-9]
echo -e "\n"

echo "########################### fstab ################################"
echo "grep -v ^# /etc/fstab |grep -v ^\$|sed 's/,/ /g'"
echo -e "fstab:\c"
grep -v ^# /etc/fstab |grep -v ^$|sed 's/,/ /g'|xargs
grep -v ^# /etc/fstab |grep -v ^$|sed 's/,/ /g'
echo -e "\n"

echo "########################### mtab  ################################"
echo "egrep ^/ /etc/mtab|sed 's/,/ /g'"
echo -e "mtab:\c"
egrep ^/ /etc/mtab|sed 's/,/ /g'|xargs
egrep ^/ /etc/mtab|sed 's/,/ /g'
echo -e "\n"

#echo "########################### mount  ###############################"
#mount
#echo -e "\n"

echo "########################### clustat ##############################"
echo "clustat"
echo -e "clustat$\c"
which clustat &> /dev/null
if [ $? -eq 0 ];then
  clustat|sed 's/,/ /g'|xargs
fi

echo -e "\n"

echo "############################ user  ###############################"
echo "awk -F: '{print\$1}' /etc/passwd|xargs"
echo -e "user:\c"
awk -F: '{print$1}' /etc/passwd|xargs
echo -e "\n"

echo "############################ group  ##############################"
echo "awk -F: '{print \$1}' /etc/group|xargs"
echo -e "group:\c"
awk -F: '{print $1}' /etc/group|xargs
echo -e "\n"

