#!/bin/bash

rm -rf /home/$(whoami)/storage
rm -rf /home/$(whoami)/www/*
sudo mysqladmin -uroot -pnewpass create opencart
echo "Installing OpenCart..."
{
cd `mktemp -d`
wget https://github.com/opencart/opencart/releases/download/3.0.3.9/opencart-3.0.3.9.zip
unzip *
mv upload/* /home/$(whoami)/www/
}&> /dev/null
php /home/$(whoami)/www/install/cli_install.php install --db_hostname localhost --db_username root --db_password newpass --db_database opencart --db_driver mysqli --db_port 3306 --username admin --password 1 --email youremail@example.com --http_server https://8080-$WEB_HOST/

# Pre-filling admin login form
sed -i "s/{{ username }}/admin/" /home/$(whoami)/www/admin/view/template/common/login.twig
sed -i "s/{{ password }}/1/" /home/$(whoami)/www/admin/view/template/common/login.twig

# Moving storage folder out of www and redefining it in both configs to get rid of the annoying pop-up
cp -r /home/$(whoami)/www/system/storage/ /home/$(whoami)/
sed -i "s#define('DIR_STORAGE', DIR_SYSTEM . 'storage/')#define('DIR_STORAGE', '/home/$(whoami)/storage/')#" /home/$(whoami)/www/admin/config.php
sed -i "s#define('DIR_STORAGE', DIR_SYSTEM . 'storage/')#define('DIR_STORAGE', '/home/$(whoami)/storage/')#" /home/$(whoami)/www/config.php

#Clean-up
rm -rf /home/$(whoami)/www/install
rm -rf /home/$(whoami)/www/config-dist.php
rm -rf /home/$(whoami)/www/admin/config-dist.php    

echo "Installing PhpMyAdmin..."
{
cd `mktemp -d`
wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/4.9.11/phpMyAdmin-4.9.11-english.zip
unzip *
rm *.zip
mkdir -p /home/$(whoami)/www/pma
mv */* /home/$(whoami)/www/pma
mv /home/$(whoami)/www/pma/config.sample.inc.php /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'cookie'/'config'/" /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'compress'] = false;/'user'] = 'root';/" /home/$(whoami)/www/pma/config.inc.php
sed -i "s/'AllowNoPassword'] = false;/'password'] = 'newpass';/" /home/$(whoami)/www/pma/config.inc.php
}&> /dev/null


echo "Restarting LEMP..."
{
sudo service php7.4-fpm restart && sudo service nginx restart && sudo service mariadb restart
}&> /dev/null
