#!/bin/bash

# Written by Kobi Shpak.
# n - number of files
# m - size of largest file
# complexity - O(m*nlogn)
# 1) find all files that have the same size as other files
# 2) check if there are files that have the same size
# 2.1) if found, there are files that have the same size, hash their content and compare hashes; generate report.
# 2.2) else, no files with same size, means that there no duplicates. make empty report.

WORKDIR=/tmp/workdir

# dispose existing workdir (in case previous run did not finish gracefully)
rm -rf $WORKDIR
mkdir -p $WORKDIR

#find all files that have the same size as other files
wc -c `find . -type f` | sort -n | awk ' { t = $1; $1 = $2; $2 = t; print; } ' | uniq -f 1 -D | awk '{print $1}' > $WORKDIR/dupesBySize.txt

#check if there are files that have the same size
if [ -s $WORKDIR/dupesBySize.txt ]
then
        #there are files that have the same size, hash their content and compare hashes
        md5sum `cat $WORKDIR/dupesBySize.txt` | sort | uniq -D -w 32 > $WORKDIR/hashed.txt

        #generate report
        init_hash=`cat $WORKDIR/hashed.txt | head -1 | awk '{print $1}'`
        counter=1
        printf "The following files are duplicates:\n$counter)"
        while read line; do
        hash=`echo $line | awk '{print $1}'`
        value=`echo $line | awk '{print $2}'`

                if [ "$init_hash" = "$hash" ]; then
                        printf "$value, "
                else
                        init_hash=$hash
                        ((counter++))
                        printf "\n$counter)$value, "
                fi
        done < $WORKDIR/hashed.txt
        printf "\n"
else
        #no files with same size, means that there no duplicates. make empty report.
        echo "No duplicates were found."
fi

# dispose workdir
rm -rf $WORKDIR