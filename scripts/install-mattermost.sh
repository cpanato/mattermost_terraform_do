#!/bin/sh
set -e

# Download the Mattermost Server.
wget https://releases.mattermost.com/3.10.0/mattermost-3.10.0-linux-amd64.tar.gz

# Extract the Mattermost Server files.
tar -xvzf mattermost*.gz

# Move the extracted file to the /opt directory.
mv mattermost /opt

# Create the storage directory for files.
mkdir /opt/mattermost/data

# Create the Mattermost user and group
useradd --system --user-group mattermost

# Set the user and group mattermost as the owner of the Mattermost files
chown -R mattermost:mattermost /opt/mattermost

# Give write permissions to the mattermost group
chmod -R g+w /opt/mattermost

rm /opt/mattermost/config/config.json
rm /etc/nginx/sites-enabled/default