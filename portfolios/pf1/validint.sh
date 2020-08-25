#!/bin/bash

while true; do

    #prompt for the user input
    read -p "Please enter a two digit numeric code (integer) that is no less than 20, and no greater than 40: " input 
    
    #check empty value
    if [[ -z "$input" ]]; then 
        clear
        echo "Empty value !!! You entered a empty value. Try again."
    #check not a number 
    elif [[ ! "$input" =~ ^[0-9]+$ ]]; then
        clear
        echo "Not a integer !!! You entered invalid value. Try again."
    #integer value input from user 
    else
        #check within the range 20 to 40, inclusive
        if [[ "$input" -ge 20 ]] && [[ "$input" -le 40 ]]; then
            clear
            echo "Correct !!! You entered a valid value. Thanks."
            exit 0
        #not in the range    
        else
            clear
            echo "Not in range !!! You entered a out of range value. Try again."
        fi
    fi 
done

