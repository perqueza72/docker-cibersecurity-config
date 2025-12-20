TARGET_DIR="${1:-$PWD}"
USERNAME=ai_user
GROUP_NAME=ai_group

echo "Folder: $TARGET_DIR"
echo "Group: $GROUP_NAME"

bash ./start-llxprt.sh $TARGET_DIR $USERNAME $GROUP_NAME