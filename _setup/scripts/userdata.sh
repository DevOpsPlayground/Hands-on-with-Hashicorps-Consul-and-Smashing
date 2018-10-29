#!/bin/bash

# Initiate Logging

exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

###### Install Ruby START ######

yum install gcc-c++ patch readline readline-devel zlib zlib-devel -y
yum install libyaml-devel libffi-devel openssl-devel make -y
yum install bzip2 autoconf automake libtool bison iconv-devel sqlite-devel -y

curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm requirements run
rvm install 2.2.4
rvm use 2.2.4 --default

###### Install Ruby END ######

###### Install Wetty START  ######

chmod 755 /root
export HOME=/root
echo "playground    ALL=(ALL)      NOPASSWD: ALL" >> /etc/sudoers

sudo yum update -y
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -  
sudo yum install curl wget nodejs make git nginx -y
sudo yum groupinstall -y 'Development Tools'

cd /opt
git clone https://github.com/krishnasrinivas/wetty.git
cd wetty
npm install --unsafe-perm -g wetty
sudo adduser playground 
echo 'PlaygroundsComputers1' | sudo passwd playground --stdin
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd reload

cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  localhost;
        root         /usr/share/nginx/html;
        location / {
            proxy_pass   http://127.0.0.1:3000;
        }
    }
}
EOF

sudo service nginx start
sudo chkconfig nginx on

sudo -u playground nohup wetty -p 3000 &


###### Install Wetty END  ######


###### Install Jenkins START  ######

yum remove java -y
yum install java-1.8.0-openjdk -y
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins -y
sed -i 's/JENKINS_JAVA_OPTIONS.*/JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/' /etc/sysconfig/jenkins
service jenkins start
chkconfig jenkins on

###### Install Jenkins END  ######


###### Install Artifactory START  ######

wget https://bintray.com/jfrog/artifactory-rpms/rpm -O bintray-jfrog-artifactory-rpms.repo
mv bintray-jfrog-artifactory-rpms.repo /etc/yum.repos.d/
yum install jfrog-artifactory-cpp-ce -y
service artifactory start
chkconfig artifactory on

###### Install Artifactory END  ######

# Get playground repo
sudo -u playground bash -c  'cd ~ && git clone https://github.com/ecsdigital/devopsplayground-sg-02-hashicorpconsulandsmashing.git'

# Install JQ for Health Check
yum install jq -y

# Install smashing 
gem install smashing