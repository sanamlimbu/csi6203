#!/bin/bash
while true; do
    read -p "Please enter the pattern to be searched for: " pattern
    echo -e "Menu option\nPress 1) For extact word match
    2) For wildcard line match
    3) For inverted match i.e retrieve lines that do not contain the pattern"
    read -p "Please enter your choice [1, 2, 3, or 4]: " opt
 
    case $opt in
        1)
            count=$(grep -E -o -i -w $pattern access_log.txt | wc -l)
            if [[ count -eq 0 ]]; then
                echo "No matches found."
            else
                echo "$count matches found."
                grep -E -n -o -i -w $pattern access_log.txt
            fi
            ;;
        2)
            count=$(grep -E -o -i $pattern access_log.txt | wc -l)
            if [[ count -eq 0 ]]; then
                echo "No matches found."
            else
                echo "$count matches found."
                grep -E -n -i $pattern access_log.txt
            fi
            ;;
        3)
            invert=$(grep -E -i -n -v $pattern access_log.txt)
            if [[ -z $invert ]]; then
                echo "Pattern matched in each line. Nothing to display"
            else
                echo "$invert"
            fi    
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
    echo "Would you like to continue the pattern search?"
    read -p "If Yes press 'y' or No press any key: " again
    if [[ $again = "y" ]]; then
        continue;
    else
        break
    fi
done

#sucessful execution
exit 0
