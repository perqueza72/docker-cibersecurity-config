#sh

FOLDER=$1
GROUP_ID=$2
if getent group "$GROUP_ID" > /dev/null; then
    echo "Group exists, do nothing"
else
    echo "Group does not exist, creating a new one"
    exit 1
fi

echo "Running on folder $FOLDER"

setfacl -R -m g:$GROUP_ID:rwx $FOLDER
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

