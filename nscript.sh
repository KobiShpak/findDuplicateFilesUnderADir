#!/bin/bash

# Written by Kobi Shpak.
# n - number of files
# m - size of largest file
# complexity - O(m*n)
# 1) create files named after possible hashes and put relevant file paths under each file
# 2) if a file has more than one path, it means there are duplicates. print it.

WORKDIR=/tmp/workdir

# dispose existing workdir (in case previous run did not finish gracefully)
rm -rf $WORKDIR
mkdir -p $WORKDIR

# create files named after possible hashes and put relevant file paths under each file
find . -type f | while read filename; do
        hashed=`md5sum $filename | awk '{print $1}'`
        touch $WORKDIR/$hashed
        echo $filename >> $WORKDIR/$hashed
done

# if a file has more than one path, it means there are duplicates. print it.
counter=1
find $WORKDIR -type f | while read filename; do
        if (( $(wc -l < "$filename") > 1 )); then
                # print file content separated by comma
                echo -e "$counter)\c"
                cat $filename | paste -sd "," -
                ((counter++))
        fi
done

# dispose workdir
rm -rf $WORKDIR