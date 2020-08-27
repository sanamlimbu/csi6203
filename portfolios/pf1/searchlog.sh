#!/bin/bash

#inverted match function 
invert_match () {
    # grepping inverted match with line number in source file
    invert=$(grep -E -i -n -v $pattern access_log.txt)
    echo "------Inverted Match Output------"
    if [[ -z $invert ]]; then #pattern match found in each line
        echo "Pattern matched in each line. Nothing to display"
    else #no pattern match in the file
         echo "$invert" #output the inverted match
    fi 
            
}

again="y"
#searching for pattern until user wants to exit
while [ $again = "y" ]; do
    #prompt and read user input
    read -p "Please enter the pattern to be searched for: " pattern
    echo -e "Menu option\nPress 1) For extact word match\n2) For wildcard line match"
    read -p "Please enter your choice [1 or 2]: " opt
    read -p "Do you want to do inverted match? If yes press "y" else any other key: " invt_opt
    
    if [[ $opt = 1 ]]; then #exact word match

        #count the number of exact word match found
        count=$(grep -E -o -i -w $pattern access_log.txt | wc -l)
        echo "------ Exact Word Match Output------"
    
        if [[ count -eq 0 ]]; then #no match found
            echo "No matches found."
        else #match found
            echo "$count matches found."
            #output extact word match with line number in source file 
            grep -E -n -o -i -w $pattern access_log.txt
        fi
        if [[ $invt_opt = "y" ]]; then #user wants inverted match
            invert_match
        fi
        
    elif [[ $opt = 2 ]]; then #wildcard line match
        #count the number of pattern match found
        count=$(grep -E -o -i $pattern access_log.txt | wc -l)
        echo "------Wildcard Line Match Output------"
        
        if [[ count -eq 0 ]]; then #no match found
            echo "No matches found."
        else #match found
            echo "$count matches found."
            #output wildcard line match with line number in source file
            grep -E -n -i $pattern access_log.txt
        fi    
        if [[ $invt_opt = "y" ]]; then #user wants inverted match
            invert_match
        fi
    else
        echo "Invaid option. Try Again"
        continue
    fi

    # prompting if wanna continue the pattern search
    echo "Would you like to continue the pattern search?"
    read -p "If Yes press 'y' or No press any other key: " again

done

#sucessful execution
exit 0
