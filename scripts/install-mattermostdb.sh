#!/bin/sh
set -e

mysql -u root -p root -e "create user 'mmuser'@'%' identified by 'mostest';"
mysql -u root -p root -e "create user 'mmuser'@'${mattermost_db}' identified by 'mmuser-password';"
mysql -u root -p root -e "create database mattermost;"
mysql -u root -p root -e "grant all privileges on mattermost.* to 'mmuser'@'%';"

