#!/bin/sh

FOLDER=$1
GROUP_ID=$2
if getent group "$GROUP_ID" > /dev/null; then
    echo "Group exists, do nothing"
else
    echo "Group does not exist, creating a new one"
    exit 1
fi

echo "Running on folder $FOLDER"

CLAUDE_JSON="$(dirname "$(readlink -f "$0")")/.claude-config/.claude.json"
if [ ! -f "$CLAUDE_JSON" ]; then
    touch "$CLAUDE_JSON"
    chmod 600 "$CLAUDE_JSON"
fi
setfacl -m "g:$GROUP_ID:rw" "$CLAUDE_JSON"

find "$FOLDER" \
    -type d \( -name node_modules -o -name dist -o -name cdk.out -o -name .llxprt-config -o -name .claude-config \) -prune \
    -o -print0 | xargs -0 -r setfacl -m g:$GROUP_ID:rwx

find "$FOLDER" \
    -type d \( -name node_modules -o -name dist -o -name cdk.out -o -name .llxprt-config -o -name .claude-config \) -prune \
    -o -type d -print0 | xargs -0 -r setfacl -d -m g:$GROUP_ID:rwx
PROTECTED_FILES=$(find $FOLDER \
    -type d \( -name node_modules -o -name dist -o -name cdk.out \) -prune \
    -o -type f -name ".env*" ! -name ".env.sample" \
    -print 2>/dev/null)

readarray -t FILES <<< "$PROTECTED_FILES"
for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
        echo "setfacl -m g:$GROUP_ID \"$f\""
        setfacl -m "g:$GROUP_ID:---" "$f"
    fi
done

