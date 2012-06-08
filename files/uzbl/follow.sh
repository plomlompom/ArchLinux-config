#!/bin/sh
# This scripts acts on the return value of followLinks in follow.js

result=$1
shift

case $result in
    XXXFORM_ACTIVEXXX)
        # a form element was selected
        echo 'event KEYCMD_CLEAR' > "$UZBL_FIFO"
        echo 'set mode = insert' > "$UZBL_FIFO"
        ;;
    XXXRESET_MODEXXX)
        # a link was selected
        echo 'event KEYCMD_CLEAR' > "$UZBL_FIFO"
        ;;
    XXXNEW_WINDOWXXX*)
        # open a new window
        echo 'event KEYCMD_CLEAR' > "$UZBL_FIFO"
        echo "event NEW_WINDOW $@" > "$UZBL_FIFO"
        ;;
    XXXRETURNED_URIXXX*)
        # copy URI to xclip primary and clipboard
        uri=${result#XXXRETURNED_URIXXX}
        echo 'event KEYCMD_CLEAR' > "$UZBL_FIFO"
        echo "$uri" | xclip
        echo "$uri" | xclip -selection clipboard
        ;;
    XXXDOWNLOADXXX*)
        # download from selected uri
        uri=${result#XXXDOWNLOADXXX}
        echo 'event KEYCMD_CLEAR' > "$UZBL_FIFO"
        echo "download $uri" > "$UZBL_FIFO"
esac
