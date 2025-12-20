#!/bin/bash

FOLDER=$1
USERNAME=$2
GROUP_NAME=$3

# Check if $1 is empty OR $2 is empty
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Error: Both arguments must be provided." >&2
    echo "Usage: $0 <argument1> <argument2> <argument3>" >&2
    exit 1
fi

if getent group "$GROUP_NAME" > /dev/null; then
    echo "Group already exists"
else
    sudo addgroup $GROUP_NAME
    sudo adduser --ingroup $GROUP_NAME $USERNAME
    sudo useradd -m -G $GROUP_NAME $USERNAME
    sudo chown -R $USER_ID:$GROUP_ID .llxprt-config
fi

GROUP_ID=$(getent group $GROUP_NAME | cut -d: -f3)
USER_ID=$(id -u $USERNAME)


bash set_private_files.sh $FOLDER $GROUP_ID

echo "Running docker compose with $USER_ID:$GROUP_ID" in folder $FOLDER
export HOST_UID_GID="$USER_ID:$GROUP_ID"
export HOST_FOLDER="$FOLDER"

docker compose up --build -d
echo "Waiting for docker compose to start..."

# Wait up to 60 seconds
# timeout=60
# while ! docker compose ps --services --filter "status=running" | grep . >/dev/null; do
#   sleep 1
#   timeout=$((timeout-1))
#   if [ $timeout -le 0 ]; then
#     echo "Timeout: compose did not start."
#     exit 1
#   fi
# done
echo "Docker compose is UP."

# Use interactive mode
docker attach ai-agents-container