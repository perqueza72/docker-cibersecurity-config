#!/bin/bash

USERNAME=ai_user
GROUP_NAME=ai_group
SCRIPT_DIR=~/workspace/docker-cibersecurity-config

if getent group "$GROUP_NAME" > /dev/null; then
    echo "Group already exists"
else
    sudo addgroup $GROUP_NAME
    sudo adduser --ingroup $GROUP_NAME $USERNAME
fi

sudo usermod -aG $GROUP_NAME $USER

GROUP_ID=$(getent group $GROUP_NAME | cut -d: -f3)
USER_ID=$(id -u $USERNAME)

sudo chown -R $USER_ID:$GROUP_ID $SCRIPT_DIR/.llxprt-config $SCRIPT_DIR/.claude-config

docker compose --file $SCRIPT_DIR/docker-compose.yml build \
  --build-arg HOST_UID=$USER_ID \
  --build-arg HOST_GID=$GROUP_ID

echo "Sandbox built. Run ./llxprt-terminal-script.sh to start a session."
