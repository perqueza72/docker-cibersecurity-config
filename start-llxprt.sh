#!/bin/bash

FOLDER=$1
shift

USERNAME=ai_user
GROUP_NAME=ai_group

MODE="llxprt"
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--mode) MODE="$2"; shift 2;;
    *) echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

if [ -z "$FOLDER" ]; then
    echo "Error: folder must be provided." >&2
    echo "Usage: $0 <folder> [-m llxprt|claude]" >&2
    exit 1
fi

CONFIG_DIR="$(dirname "$(readlink -f "$0")")"
CLAUDE_CREDS="$CONFIG_DIR/.claude-config/.credentials.json"

case $MODE in
  llxprt) export CONTAINER_CMD="llxprt --yolo";;
  claude)
    if [ ! -f "$CLAUDE_CREDS" ]; then
      echo "No Claude credentials found → starting interactive auth (plain 'claude')."
      echo "After login, exit and re-run for --dangerously-skip-permissions mode."
      export CONTAINER_CMD="claude"
    else
      export CONTAINER_CMD="claude --dangerously-skip-permissions"
    fi
    ;;
  *) echo "Unknown mode: $MODE. Use 'llxprt' or 'claude'." >&2; exit 1;;
esac

echo "Mode: $MODE → $CONTAINER_CMD"

GROUP_ID=$(getent group $GROUP_NAME | cut -d: -f3)

bash ~/workspace/docker-cibersecurity-config/set_private_files.sh "$FOLDER" $GROUP_ID

echo "Starting container for $FOLDER"

docker rm -f ai-agents-container 2>/dev/null || true

HOST_FOLDER="$FOLDER" docker compose --file ~/workspace/docker-cibersecurity-config/docker-compose.yml run --rm app
