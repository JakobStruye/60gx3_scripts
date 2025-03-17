#!/bin/bash
echo $1
tail -f $1 | while read line; do echo "$(date +'%Y:%m:%d-%H:%M:%S.%N') $line"; done > $1.log
