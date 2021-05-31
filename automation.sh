#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
myname=Dibyendu
s3_bucket=upgrad-dibyendu
#to check if apache2 installed or not
apt update -y
if [ $(dpkg-query -W -f='${Status}' apache2 | grep -c "install ok installed") -eq 0 ]
then
        apt install apache2
else
        echo "Apache2 is already installed"
fi
#to check status of apache2
if [ "$(systemctl is-active apache2)" = "inactive" ]; then
    service apache2 start
else
    echo "Apache2 is already running"
fi
#check if apache2 service is enabled
if [ "$(systemctl is-enabled apache2)" != "enabled" ]; then
    systemctl enable apache2.service
else
    echo "Apache2 service is already enabled"
fi
#move log files to s3
mkdir -p /tmp/log
cp /var/log/apache2/*.log /tmp/log
cd /tmp
tar -cvf ${myname}-httpd-logs-${timestamp}.tar log
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
#ectract info to html file
if [ ! -f /var/www/html/inventory.html ]
then
        touch /var/www/html/inventory.html
        echo -e '\t'LogType'\t''\t'Date Created'\t''\t'Type'\t'Size >> /var/www/html/inventory.html
else
        echo "Inventory.html file exists"
fi
type=$(ls -ltr /tmp/${myname}-httpd-logs-${timestamp}.tar|awk '{print $9}'| cut -d'.' -f2)
size=$(ls -lah /tmp/${myname}-httpd-logs-${timestamp}.tar| awk '{ print $5}')
log_type=$(ls -ltr /tmp/${myname}-httpd-logs-${timestamp}.tar|awk '{print $9}'| cut -d'-' -f2-3)
echo -e '\n''\t'$log_type'\t'$timestamp'\t''\t'$type'\t'$size >> /var/www/html/inventory.html
rm -rf /tmp/log
#to schedule cron
if [ ! -f /etc/cron.d/automation ]
then
        touch /etc/cron.d/automation
                grep 'root /root/Automation_Project/automation.sh' /etc/cron.d/automation || echo '0 10 * * * root /root/Automation_Project/automation.sh' >> /etc/cron.d/automation
fi
