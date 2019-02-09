#!/bin/bash

# Written by Kobi Shpak.
# n - number of files
# m - size of largest file
# complexity - O(m*nlogn)
# 1) find all files that have the same size as other files
# 2) check if there are files that have the same size
# 2.1) if found, there are files that have the same size, hash their content and compare hashes; generate report.
# 2.2) else, no files with same size, means that there no duplicates. make empty report.

########################################################
####################### Constants ######################
########################################################
WORKDIR=/tmp/workdir

########################################################
####################### Functions ######################
########################################################

getPathsWithSize() {
	IFS=$'\n'
	while read -r line; do
			wc -c $line >> $WORKDIR/pathsWithSizes.txt
	done < $WORKDIR/allFilePaths.txt
}

getDupesBySize() {
	awk 'NR==FNR{c[$1]++;next} c[$1]>1' $WORKDIR/pathsWithSizes.txt $WORKDIR/pathsWithSizes.txt |\
	cut -f 2- -d ' ' > $WORKDIR/dupesBySize.txt
}

getDuplicatesHasehsWithPaths() {
	IFS=$'\n'
	while read -r line; do	
		md5sum $line >> $WORKDIR/hashesWithPaths.txt
	done < $WORKDIR/dupesBySize.txt
	sort -n $WORKDIR/hashesWithPaths.txt |\
	uniq -D -w 32 > $WORKDIR/sortedHashesWithPaths.txt
}

generateReport() {
	init_hash=`cat $WORKDIR/sortedHashesWithPaths.txt | head -1 | awk '{print $1}'`
	counter=1
	printf "The following files are duplicates:\n$counter)"
	while read line; do
		hash=`echo $line | awk '{print $1}'`
		value=`echo $line | cut -f 2- -d ' '`
		
		if [ "$init_hash" = "$hash" ]; then
			printf "$value, "
		else
			init_hash=$hash
			((counter++))
			printf "\n$counter)$value, "
		fi
		done < $WORKDIR/sortedHashesWithPaths.txt
		printf "\n"
}

########################################################
######################## Main ##########################
########################################################

# dispose existing workdir (in case previous run did not finish gracefully)
rm -rf $WORKDIR
mkdir -p $WORKDIR

read -p 'Enter dir path to search for duplicate files in it (Press enter to search in current dir): ' path
if [[ $path == '' ]]; then
	path='.'
fi

# save all file paths under wanted dir
find $path -type f > $WORKDIR/allFilePaths.txt

# generate a file that shows the byte size of each file path
getPathsWithSize

# generate a file with all file paths that have the same size as other files
getDupesBySize

#check if there are files that have the same size
if [ -s $WORKDIR/dupesBySize.txt ]
then
	#there are files that have the same size, hash their content and compare hashes
	getDuplicatesHasehsWithPaths
	
	#generate report
    generateReport
	
else
    #no files with same size, means that there no duplicates. make empty report.
    echo "No duplicates were found."
fi

# dispose workdir | comment below if you need to keep the files for debug
rm -rf $WORKDIR
