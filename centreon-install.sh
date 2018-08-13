#!/bin/sh
##### Centos 7
yum install -y wget git perl-CPAN
#### for Smart Array P410i 
wget https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1257348637/v76502/hpacucli-9.20-9.0.x86_64.rpm
rpm -ivh hpacucli-9.20-9.0.x86_64.rpm 
#### for Dynamic Smart Array B140i
wget https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1857046646/v114618/hpssacli-2.40-13.0.x86_64.rpm
rpm -ivh hpssacli-2.40-13.0.x86_64.rpm
#### check_raid
git clone https://github.com/glensc/nagios-plugin-check_raid.git
cd nagios-plugin-check_raid
curl -LO http://xrl.us/cpanm
perl cpanm --installdeps .
#### patch check_raid script
sed '2i export INFOMGR_BYPASS_NONSA=1' check_raid.sh  > check_raidnew.sh
cp check_raidnew.sh check_raid.sh
cp -r ../nagios-plugin-check_raid/ /usr/lib64/nagios/plugins/
#### add new command to nrpe 
echo "command[check_raid]=/usr/bin/sudo /usr/lib64/nagios/plugins/nagios-plugin-check_raid/check_raid.sh" >> /etc/nrpe.d/op5_commands.cfg
echo "command[check_pacemaker]=/usr/bin/sudo /usr/sbin/crm_mon -s" >> /etc/nrpe.d/op5_commands.cfg
####
cp /etc/sudoers /root/sudoers_backup
cat /etc/sudoers | sed 's/jstat/jstat, \/usr\/sbin\/hpacucli, \/usr\/lib64\/nagios\/plugins\/nagios-plugin-check_raid\/check_raid.sh,  \/usr\/sbin\/crm_mon -s/g' > /root/sudoers
cp -r /root/sudoers /etc/sudoers
#### restart nrpe
systemctl restart nrpe


