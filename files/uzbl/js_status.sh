#!/bin/sh

if [ $1 == 1 ]; then
  echo 'set status_js = <span foreground="#0f0">j</span>' > $UZBL_FIFO
else
  echo 'set status_js = <span foreground="#070">j</span>' > $UZBL_FIFO
fi
