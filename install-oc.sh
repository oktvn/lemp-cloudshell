#!/bin/bash
source /etc/environment

if [[ $EUID -eq 0 ]]; then
   echo "This script must be run as a non-root user" 
   exit 1
fi

oc_version="3.0.3.9"
php_version="8.x"

rm -rf /home/$(whoami)/www/*
sudo mysql -uroot -pnewpass -e "DROP DATABASE IF EXISTS opencart"
sudo mysql -uroot -pnewpass -e "CREATE DATABASE opencart"

echo "Installing OpenCart..."
{
cd `mktemp -d`
wget "https://github.com/opencart/opencart/releases/download/$oc_version/opencart-$oc_version.zip"
unzip *
find $PWD -maxdepth 2 -type d -name 'upload' -exec sh -c 'cp -r "{}"/* /home/$(whoami)/www/' \;
}&> /dev/null

# Turn on SEO URLs
sed -i "s/'config_seo_url', '0'/'config_seo_url', '1'/" /home/$(whoami)/www/install/opencart.sql

mv /home/$(whoami)/www/config-dist.php /home/$(whoami)/www/config.php 
mv /home/$(whoami)/www/admin/config-dist.php /home/$(whoami)/www/admin/config.php 

php /home/$(whoami)/www/install/cli_install.php install --db_hostname localhost --db_username root --db_password newpass --db_database opencart --db_driver mysqli --db_port 3306 --username admin --password password1 --email youremail@example.com --http_server "https://8080-$WEB_HOST/"

# Pre-filling admin login form
sed -i "s/{{ username }}/admin/" /home/$(whoami)/www/admin/view/template/common/login.twig
sed -i "s/{{ password }}/password1/" /home/$(whoami)/www/admin/view/template/common/login.twig

# 4.x compatibility
sed -i 's/name="username" value=""/name="username" value="admin"/' /home/$(whoami)/www/admin/view/template/common/login.twig
sed -i 's/name="password" value=""/name="password" value="password1"/' /home/$(whoami)/www/admin/view/template/common/login.twig

# Supressing storage move notification
sed -i 's/public function index() {/public function index() { return;/' /home/$(whoami)/www/admin/controller/common/security.php

#Clean-up
rm -rf /home/$(whoami)/www/install/*/
rm -rf /home/$(whoami)/www/install/index.php
rm -rf /home/$(whoami)/www/config-dist.php
rm -rf /home/$(whoami)/www/admin/config-dist.php    


echo "Installing PhpMyAdmin for PHP 8 at https://8080-$WEB_HOST/pma/..."
{
cd `mktemp -d`
wget --no-check-certificate "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-english.zip"
unzip *
rm *.zip
mkdir -p /home/$(whoami)/www/pma
mv */* /home/$(whoami)/www/pma
mv /home/$(whoami)/www/pma/config.sample.inc.php /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'cookie'/'config'/" /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'compress'] = false;/'user'] = 'root';/" /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'AllowNoPassword'] = false;/'password'] = 'newpass';/" /home/$(whoami)/www/pma/config.inc.php
}&> /dev/null
