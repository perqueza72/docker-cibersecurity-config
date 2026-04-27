#!/bin/bash
USERNAME=ai_user
GROUP_NAME=ai_group

if [[ "$1" == -* ]] || [[ -z "$1" ]]; then
    TARGET_DIR="$PWD"
else
    TARGET_DIR="$1"
    shift
fi

echo "Folder: $TARGET_DIR"
echo "Group: $GROUP_NAME"

bash ~/workspace/docker-cibersecurity-config/start-llxprt.sh "$TARGET_DIR" "$@"