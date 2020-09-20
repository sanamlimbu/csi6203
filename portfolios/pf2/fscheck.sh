#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

#function that displays proporties (word count, file size,
#last modified date) of a given file
getprop()
{
    word_count=$(cat $1 | wc -w) #count words in the file
   
    file_bytes=$(du -b $1 | cut -f1) #get file size in bytes
    
    #change bytes to kilobytes using awk to deal with float value
    file_kbytes=$( echo $file_bytes | awk '{kb=$1/1024; printf"%.2f\n", kb}' ) 
    
    last_modified_date=$(date -r $1 +"%d-%m-%Y %H:%M:%S") #get file last modified date and format it
    
    #display the properties in terminal
    echo "The file $1 contains ${word_count} words and is ${file_kbytes}K in size and was last modified ${last_modified_date}" 
}

#prompt user to enter filename
read -p "Please enter the file name to check: " fname

#calling the function to check proporties of the given file
getprop $fname

exit 0 #successful execution