#!/bin/bash

#stop logging services
/usr/bin/systemctl rsyslog stop
/usr/bin/systemctl auditd stop

#remove old kernels
/bin/package-cleanup --oldkernels --count=1 -y

#clean yum cache
/usr/bin/yum clean all

#force logrotate to shrink logspace and remove old logs as well as truncate logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

#remove udev hardware rules
/bin/rm -f /etc/udev/rules.d/70*

#remove nic mac addr and uuid from ifcfg scripts
/bin/sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-*

#remove SSH host keys
/bin/rm -f /etc/ssh/*key*

#remove root users shell history
/bin/rm -f ~root/.bash_history
unset HISTFILE

#remove root users SSH history
/bin/rm -rf ~root/.ssh/

#engage logrotate to shrink logspace used
/usr/sbin/logrotate -f /etc/logrotate.conf

# Disable Firewall
echo "Disable Firewall"
systemctl stop firewalld
systemctl disable firewalld
echo "Done"

# Disable SELinux
echo "Disable SELinux"
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
sudo sestatus

#and lets shutdown
init 0
