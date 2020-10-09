#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

#download the given page and grab all the image urls from img tags into the img_url_list array
img_url_list=($(curl -s "https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus" | grep img | grep -Eo 'https://[^"]+'))

len=${#img_url_list[@]} #total number of elements in img_url_list array

#text file to hold all the directories and files names created by the script
delete="delete.txt"

#get the file size in KB
get_file_size(){
    file_path=$1
    file_bytes=$(du -b $file_path | cut -f1) #get file size in bytes
    #change bytes to kilobytes using awk to deal with float value
    file_kbytes=$( echo $file_bytes | awk '{kb=$1/1024; printf"%.2f\n", kb}' ) 
    echo "$file_kbytes KB"
}

#get directory to save file from user
get_dir(){
    #while $dircondition; do
        read -p "Enter the name of directory into which you want to download image: " dirname
        if [ ! -d $dirname ]; then #directory not exist so make directory
            mkdir $dirname

            #append the created directory name to the delete.txt file 
            touch $delete
            echo "$dirname" >> $delete
        fi
        echo $dirname #echo to return directory name
    #done 
} 

#download the image file with given url
download(){
    img_url=$1 #url of the image file as first argument
    img_name=$(sed 's/.*\///' <<< $img_url) #get the file name
    dirname=$2 #directory to save file
    if [[ -f $dirname/$img_name ]]; then #imge file present in the directory
        echo "$img_name file is present in the directory."
        read -p "If you want to overwrite, press [y/Y] or want to skip then press any key: " doption
        if [[ $doption == "y" || $doption == "Y" ]]; then #want to overwrite
            #wget -q $img_url -P $dirname #download the file and overwrite
            (cd $dirname && curl -s $img_url > $img_name)
            
            #append the downloaded file name to the delete.txt file 
            touch $delete
            echo "$dirname/$img_name" >> $delete

            #displaying the download progress info
            echo "Downloading ${img_name%.*}, with the file name ${img_name}, with a file size of $(get_file_size $dirname/$img_name)….File Download Complete"
        fi
    else #file not present in the directory
        wget -q $img_url -P $dirname #download the file

        #append the downloaded file name to the delete.txt file 
        touch $delete
        echo "$dirname/$img_name" >> $delete

        #displaying the download progress info
        echo "Downloading ${img_name%.*}, with the file name ${img_name}, with a file size of $(get_file_size $dirname/$img_name)….File Download Complete"
    fi 
}

validate_img_name(){
    img_name=$1
    if [[ ${#img_name} == 4 && $img_name =~ ^[0-9]+$ ]]; then
        true
    else
        false
    fi
}

get_img_url(){
    img_name=$1
    for item in "${img_url_list[@]}"; do
        img_url="$(echo $item | grep "${img_name}.jpg$")" #grab the url of the file from img_url_list
        if [ "$img_url" ]; then
            break
        fi
    done
    echo "$img_url"

}

#display the properties of the directory where images are downloaded
get_dir_prop(){
    dirname=$1

}

cleanup(){
    if [ -f "$delete" ]; then

        original_IFS=$IFS #save original IFS to a variable 
        IFS=$'\n' #make newline a $IFS

        #read values from values.txt file into the VALUES array
        declare -i i=0 
        for line in $(cat $delete); do
            if [ -f "$line" ]; then
                rm -r $line
            elif [ -d "$line" ]; then
                rm -r $line
            fi
            ((i++))
        done

        IFS=$original_IFS #restore the original value of IFS

        rm "$delete"
    fi     
}

#continue the menu options until user wants to voluntarily exit
while true; do
    echo -e "Please select a option.\n<<<<Menu Options>>>>"
    echo -e "1) Download a specific thumbnail.\n2) Download thumbnails in a given range.\n3) Download a specific number of thumbnails in a given range."
    echo -e "4) Download all thumbnails.\n5) Clean up all files created by the script.\n6) Exit Program."
    read -p "Please enter a option [1-6]: " option
    case $option in
        1)
            clear
            echo "You have selected option (1) to download a specific thumbnail. "
            read -p "Please enter the last 4 digits of the file: " img_name
            while true; do
                if validate_img_name $img_name; then
                    img_url=$(get_img_url $img_name)
                    if [ $img_url ]; then #image url is present for user entered image name
                        dirname=$(get_dir) #get directory to save file
                        #downlad the image and show download progress 
                        download $img_url $dirname
                        break
                    else #no url for the given image name 
                        echo "No such file exists. Try again."
                        read -p "Please enter the last 4 digits of the file: " img_name
                    fi
                    
                else #invalid input for the image name
                    echo "Invalid input. Please try Again."
                    read -p "Please enter the last 4 digits of the file: " img_name
                fi
            done
            ;;

        2)
            clear
            echo "You have selected option (2) to download thumbnails in a given range. "
            dirname=$(get_dir) #get directory to save file
            read -p "Please enter start of the range: " start
            while true; do
                if validate_img_name $start; then
                    read -p "Please enter end of the range: " end
                    if validate_img_name $end; then
                        if (( 10#$end >= 10#$start )); then
                            count=0
                            for i in $(seq -w $start $end); do
                                img_url=$(get_img_url ${i}) #get url of the image file
                                if [ ! -z "$img_url" ]; then #image url present in the img_url_list
                                    ((count++))
                                    download $img_url $dirname
                               fi
                            done
                            if [ "$count" == 0 ]; then
                                echo "No any thumbnail files found in the given range."
                            fi
                            break
                        else
                            echo "Invalid input. Please try again."
                            echo "End of the range should not be less than start of the range."
                        fi
                    else
                        echo "Invalid input. Please try again."
                    fi
                else
                    echo "Invalid input. Please try again."
                    read -p "Please enter start of the range: " start
                fi
            done
            ;;

        3)
            clear
            echo "You have selected option (3) to download a specific number of thumbnails in a given range. "
            dirname=$(get_dir) #get directory to save file
            read -p "Please enter start of the range: " start
            while true; do
                if validate_img_name $start; then
                    read -p "Please enter end of the range: " end
                    if validate_img_name $end; then
                        if (( 10#$end >= 10#$start )); then
                            range=$((10#$end - 10#$start + 1))
                            temp=$((range+1)) 
                            echo $range
                            echo "Please enter the number of thumbnails you want to download." 
                            read -p "The number should be integer value greater than 0 and less than $temp : " num  
                            while true; do
                                if [[ $num =~ ^[0-9]+$ ]]; then
                                    if (( 0 < $num && $num < $temp )); then
                                        break
                                    else
                                        echo "Invalid input. Please try again."
                                        echo "Please enter the number of thumbnails you want to download." 
                                        read -p "The number should be integer value greater than 0 and less than $temp : " num
                                    fi  
                                else
                                    echo "Invalid input. Please try again."
                                    echo "Please enter the number of thumbnails you want to download." 
                                    read -p "The number should be integer value greater than 0 and less than $temp : " num  
                                fi
                            done 
        
                            count=0
                            #array of user entered range 
                            range_list=($(seq -w $start $end))
                    
                            #generate array of user entered size containing unique random numbers 
                            #in the given range by user and sort them in ascending order 
                            first_index=0 
                            last_index=$((${#range_list[@]}-1))  
                            random_list=($(shuf -i $first_index-$last_index -n $num | sort -n))
                            for i in "${random_list[@]}"; do
                                img_url=$(get_img_url "${range_list[$i]}")
                                if [ ! -z "$img_url" ]; then #image url present in the img_url_list
                                    download $img_url $dirname #download image
                                    ((count++))
                                fi 
                            done
                            if [ "$count" == 0 ]; then
                                echo "No any thumbnail files found in the given range."
                            fi

                            break
                        else
                            echo "Invalid input. Please try again."
                            echo "End of the range should not be less than start of the range."
                        fi
                    else
                        echo "Invalid input. Please try again."
                    fi
                else
                    echo "Invalid input. Please try again."
                    read -p "Please enter start of the range: " start
                fi
            done
            ;;

        4)
            clear
            echo "You have selected option (4) to download all thumbnails."
            dirname=$(get_dir) #get directory to save file

            #loop through all the elements in img_url_list array 
            for (( j=0; j<$len; j++ )); do # len -> total no. of elements in img_url_list  
                img_url=${img_url_list[$j]} #get image url
                if [ ! -z "$img_url" ]; then #image url present in the img_url_list
                    download $img_url $dirname #download the image 
                fi
            done
            ;;

        5)
            clear
            echo "You have selected option (5) to clean up ALL files."
            cleanup
            echo "Clean up comleted."
            ;;
        6)
            echo "Program exit."
            break
            ;;
        *)
            echo "Invalid option. Try again"
            ;;
    esac
done
exit 0 # successful execution
