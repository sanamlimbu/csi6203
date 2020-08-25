#!/bin/bash 

#path of the directory
path=$1

#user entered directory name 
directory=$(basename $path)

#count of the empty files, non-empty files,
#empty directory, and non-empty directory
#initialized to zero
declare -i count_empty_file=0
declare -i count_non_empty_file=0
declare -i count_empty_dir=0
declare -i count_non_empty_dir=0

#looping through the directory
for i in $(ls $path); do
    df="$path/$i" #path of the file in the directory 
    #check if a directory
    if [[ -d $df ]]; then
        #empty directory
        if [[ -z "$(ls $df)" ]]; then
            ((count_empty_dir++))
        #non-empty directory
        else
            ((count_non_empty_dir++))
        fi
    #check if a file
    elif [[ -f $df ]]; then
        #non-empty file
        if [[ -s $df ]]; then
            ((count_non_empty_file++))
        #empty file
        else    
            ((count_empty_file++))
        fi
    # not regular file or directory
    else
        echo "$i is not a regular file or directory."
    fi
done

echo "The $directory directory contains:
        $count_non_empty_file files that contain data
        $count_empty_file files that are empty
        $count_non_empty_dir non-empty diirectories
        $count_empty_dir empty directories"

#successful execution
exit 0

