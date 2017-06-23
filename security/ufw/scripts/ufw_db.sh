#!/bin/sh
set -e

ufw --force reset
ufw allow ssh
ufw allow from ${mattermost_server} to any port 3306
ufw default deny incoming
ufw --force enable
ufw status verbose
