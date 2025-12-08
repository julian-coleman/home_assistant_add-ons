#!/bin/sh
#
# Upload a configuration file

CONFIG_DIR=/config
OVPN=$CONFIG_DIR/client.ovpn
TEXT=$CONFIG_DIR/client.text
TMP=$CONFIG_DIR/tmpfile

if [ "$QUERY_STRING" = "ovpn=" ]; then
    FILE=$OVPN
elif [ "$QUERY_STRING" = "text=" ]; then
    FILE=$TEXT
fi

echo Content-type: text/plain
echo

echo -n > $TMP
if [ $? -ne 0 ]; then
    echo Upload failed: create error
    exit
fi

# Find the separator from $CONTENT_TYPE
sep="${CONTENT_TYPE#*boundary=}"

# The file is the lines between the content type + 1 and separator - 1
# Write this to a temporary file
found=0
count=0
output=0
while read line;
do
    count=$((count + 1))

    # Check the file name
    case "$line" in
        Content-Disposition*filename=\"\"*)
            echo Upload failed: missing file name
            exit
        ;;
    esac

    # We want text/plain or application/octet-stream
    case "$line" in
        Content-Type:*text/plain*|Content-Type:*application/octet-stream*)
            found=$((count + 1)) # Skip following empty line
        ;;
        Content-Type:*)
            echo Upload failed: wrong file type
            exit
    esac

    # The last 2 lines are blank then separator, so skip them
    if [ $found -gt 0 ] && [ $count -gt $found ]; then
        case "$line" in
            --$sep--*)
                break
            ;;
            *)
                # Don't output the previous line the first time
                if [ $output -eq 1 ]; then
                    echo $prev >> $TMP
                fi
                prev="$line"
                output=1
            ;;
        esac
    fi
done
if [ $? -ne 0 ]; then
    echo Upload failed: write error
    exit
fi

# Rename to the real file
chmod 0644 $TMP
mv $TMP $FILE
if [ $? -ne 0 ]; then
    echo Upload failed: rename error
    exit
fi

echo Upload succeeded
cd $CONFIG 
ls -l $FILE
