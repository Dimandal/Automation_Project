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
rm -rf /tmp/log
