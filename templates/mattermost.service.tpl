[Unit]
Description=Mattermost
After=network.target

[Service]
Type=simple
ExecStart=/opt/mattermost/bin/platform
Restart=always
RestartSec=10
WorkingDirectory=/opt/mattermost
User=mattermost
Group=mattermost
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target