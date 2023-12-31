#!/bin/bash

echo "Installing PHP FPM 7.4 and extensions..."
{
sudo apt update;  sudo apt install -y nginx php7.4-fpm php7.4-curl php7.4-zip php7.4-gd php7.4-pgsql
}&> /dev/null

echo "Configuring PHP 7.4..."
{
sudo sed -i "s/www-data/$(whoami)/" /etc/php/7.4/fpm/pool.d/www.conf 
sudo mkdir -p /run/php
}&> /dev/null


echo "Installing Nginx..."
{
sudo apt install -y nginx 
}&> /dev/null

echo "Configuring Nginx..."
{
sudo cp ./default.nginx.conf /etc/nginx/sites-enabled/default
sudo sed -i "s#root /var/www/html;#root /home/$(whoami)/www;#" /etc/nginx/sites-enabled/default
sudo sed -i "s/user www-data;/user $(whoami);/" /etc/nginx/nginx.conf
mkdir -p /home/$(whoami)/www
if [ ! -d "/home/$(whoami)/www" ]; then
    cp -R /var/www/html/. "$destination"
    echo "Copied contents from /var/www/html/ to $destination"
else
    echo "$destination already exists. Skipping copy."
fi
}&> /dev/null


echo "Installing MariaDB..."
{
# We might need to remove some legacy packages
# We might need to point the storage to the home folder
sudo apt install -y mariadb-server
}&> /dev/null

echo "Configuring MariaDB..."
{
sudo service mariadb stop
sudo mkdir -p /run/mysqld
sudo chown mysql:mysql /run/mysqld/
if [ ! -d "/home/$(whoami)/mysql" ] || [ "$1" == "--first-run" ]; then
    mkdir -p /home/$(whoami)/mysql
    sudo mysql_install_db --datadir=/home/$(whoami)/mysql
    echo "Created new MySQL datadir in /home/$(whoami)"
else
    echo "MySQL datadir already exists in /home/$(whoami). Leaving as-is."
fi
sudo sed -i "s#/var/lib/mysql#/home/$(whoami)/mysql#" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo service mariadb start
sudo mysqladmin -u root password 'newpass'
}

echo "Installing MailCatcher..."
{
gem install mailcatcher --no-document
}&> /dev/null

echo "Starting MailCatcher on :8888..."
{
mailcatcher --http-port=8888
}

if [ "$1" == "--first-run" ]; then
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
fi

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

