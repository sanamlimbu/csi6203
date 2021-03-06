#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

#array to hold values read from the text file
declare -a VALUES

original_IFS=IFS #save original IFS to a variable 
IFS=$'\n' #make newline a $IFS

#read values from values.txt file into the VALUES array
declare -i i=0 
for line in $(cat values.txt); do
    VALUES[$i]="$line"
    ((i++))
done

IFS=original_IFS #restore the original value of IFS

len=${#VALUES[*]} #total number of elements in VALUES array

#loop through all the elements in VALUES array 
for (( j=0; j<${len}; j++ )); do
    value=${VALUES[$j]}
    #value contains number only
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "$value is comprised of numbers only"
    #value conatins letters only
    elif [[ "$value" =~ ^[a-zA-Z]+$ ]]; then
        echo "$value is comprised of letters only"
    #value contains numbers and letters 
    else
        echo "$value is comprised of numbers and letters"
    fi
done

exit 0 #successful execution 
