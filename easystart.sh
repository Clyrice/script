#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/easystart.sh | bash

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

export green='\033[0;32m'
export plain='\033[0m'

read "Download link: " -e URL
read "NAME of the service: " -e NAME
read "Start command: " -e DO

echo "Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "Generate /etc/systemd/system/$NAME.service"
cat <<EOF > /etc/systemd/system/$NAME.service
[Unit]
Description=$NAME

[Service]
ExecStart=/root/$NAME $DO
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "4. Enable $NAME Service"
systemctl enable $NAME.service

echo "5. Start $NAME Service"
systemctl start $NAME.service

if systemctl status $NAME >/dev/null; then
	echo "$NAME started."
	echo -e "${green}vi /etc/systemd/system/$NAME.service${plain} as needed."
	echo -e "${green}killall -9 $NAME${plain} for restart."
else
	echo "$NAME start failed."
fi