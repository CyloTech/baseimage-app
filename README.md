For information on the base image: 
https://github.com/phusion/baseimage-docker

A basic child example is ubuntulemp2-app
A full child example of this app is the wordpress-app.

Available Variables:

APEX_CALLBACK - Set false to disable parent callback
INSTALL_NGINXPHP - Set true to install nginx & php-fpm 7
INSTALL_MYSQL - Set to true to install MySQL Server
MYSQL_ROOT_PASS - Defaults to mysqlr00t

if MYSQL is installed the following variables are available:

DB_NAME, DB_USER, DB_PASS
A cron will automatically be setup to sqldump DB_NAME to /home/appbox/mysql/backup/${DB_NAME}_backup.sql daily.

