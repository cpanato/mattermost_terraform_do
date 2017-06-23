#!/bin/sh
set -e

ufw --force reset
ufw allow ssh
ufw allow 80
ufw allow 443
ufw default deny incoming
ufw --force enable
ufw status verbose
