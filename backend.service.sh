[Unit]
Description = Backend Service

[Service]
User=expense
Environment=DB_HOST="172.31.86.109"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend

[Install]
WantedBy=multi-user.target