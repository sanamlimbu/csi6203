#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

#download the given page and grab all the image urls from img tags into the img_url_list array
img_url_list=($(curl -s "https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus" | grep img | grep -Eo 'https://[^"]+'))

len=${#img_url_list[@]} #total number of elements in img_url_list array

#text file to hold all the directories and files names created by the script
delete="delete.txt"

#get the file size in bytes and KB
get_file_size(){
    file_path=$1 #file path
    file_bytes=$(du -b $file_path | cut -f1) #get file size in bytes
    #change bytes to kilobytes using awk to deal with float value
    file_kbytes=$( echo $file_bytes | awk '{kb=$1/1024; printf"%.2f\n", kb}' ) 
    echo "$file_bytes $file_kbytes" 
}

#get directory to save file from user
get_dir(){
    while true; do
        echo "Enter the name of directory into which you want to download image."
        echo "Directory name should not be absolute path."
        read -p "It should be alphanumeric[0-9a-zA-Z]: " dirname
        if [[ $dirname =~ ^[0-9a-zA-Z]+$ ]]; then 
            if [ ! -d $dirname ]; then #directory not exist so make directory
                mkdir $dirname
                #append the created directory name to the delete.txt file 
                touch $delete
                echo "$dirname" >> $delete
            fi  
            break 
        else
            echo "Invalid input. Try again."   
        fi
    done
} 

#download the image file with given url and display download progress
download(){
    img_url=$1 #url of the image file as first argument
    img_name=$(sed 's/.*\///' <<< $img_url) #get the file name
    dirname=$2 #directory to save file
    if [[ -f $dirname/$img_name ]]; then #imge file present in the directory
        echo "$img_name file is present in the directory."
        read -p "If you want to overwrite, press [y/Y] or want to skip then press any key: " doption
        if [[ $doption == "y" || $doption == "Y" ]]; then #want to overwrite
            
            #download the file and overwrite
            (cd $dirname && curl -s $img_url > $img_name)
            
            #append the downloaded file path to the delete.txt file 
            touch $delete
            echo "$dirname/$img_name" >> $delete

            #get the size of the file in bytes and kilobytes
            read bytes kbytes < <(get_file_size "$dirname/$img_name") 

            #displaying the download progress info
            echo "Downloading ${img_name%.*}, with the file name ${img_name}, with a file size of $kbytes KB….File Download Complete"
            
            ((total_count++)) #increase the count of total downloaded file
            total_size=$((total_size + bytes)) #add the file size bytes to total size
        fi
    else #file not present in the directory
        wget -q $img_url -P $dirname #download the file

        #append the downloaded file path to the delete.txt file 
        touch $delete
        echo "$dirname/$img_name" >> $delete

        #get the size of the file in bytes and kilobytes
        read bytes kbytes < <(get_file_size "$dirname/$img_name")
        
        #displaying the download progress info
        echo "Downloading ${img_name%.*}, with the file name ${img_name}, with a file size of $kbytes KB….File Download Complete"
        
        ((total_count++)) #increase the count of total downloaded file
        total_size=$((total_size + bytes)) #add the file size bytes to total size
    fi 
}

#image name validation
validate_img_name(){
    img_name=$1 #image name as 1st argument
    #valid image name
    if [[ ${#img_name} == 4 && $img_name =~ ^[0-9]+$ ]]; then
        true
    else
        false
    fi
}

#get URL of the given image name
get_img_url(){
    img_name=$1 #image name as 1st argument
    #loop through the array of image URL to get the URL for the given image name
    for item in "${img_url_list[@]}"; do
        img_url="$(echo $item | grep "${img_name}.jpg$")" #grab the url of the file from img_url_list
        if [ "$img_url" ]; then
            break
        fi
    done
    echo "$img_url"

}

#get the range from user
get_range(){
    read -p "Please enter start of the range: " start
    while true; do
        if validate_img_name $start; then
            read -p "Please enter end of the range: " end
            if validate_img_name $end; then
                if (( 10#$end >= 10#$start )); then
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
}

#delete all the files and directories created by the script 
cleanup(){
    if [ -f "$delete" ]; then

        original_IFS=$IFS #save original IFS to a variable 
        IFS=$'\n' #make newline a $IFS

        #read line by line from delete.txt file
        for line in $(cat $delete); do
            if [ -f "$line" ]; then
                rm -r $line
            elif [ -d "$line" ]; then
                rm -r $line
            fi
            ((i++))
        done

        IFS=$original_IFS #restore the original value of IFS

        rm "$delete" #delete delete.txt file
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
                        get_dir #get directory to save file
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
            get_dir #get directory to save file

            get_range #get the start and end value of the range 
            
            total_size=0 #total size of downloaded files in bytes
            total_count=0 #total number of downloaded files
            count=0 #count for the URL present 

            for i in $(seq -w $start $end); do
                img_url=$(get_img_url ${i}) #get url of the image file
                if [ ! -z "$img_url" ]; then #image url present in the img_url_list
                    ((count++))
                    download $img_url $dirname
                fi
            done
            if (( "$total_count" > 1 )); then
                if (( "$total_count" >= 1048576 )); then
                    megabytes=$( echo $total_size | awk '{mb=$1/1048576; printf"%.2f\n", mb}' )
                    echo "$total_count files of total size $megabytes MB are downloaded."
                else
                    kilobytes=$( echo $total_size | awk '{kb=$1/1024; printf"%.2f\n", kb}' ) 
                    echo "$total_count files of total size $kilobytes KB are downloaded." 
                fi
            fi
            if (( "$count" == 0 )); then
                echo "No any thumbnail files found in the given range."
            fi         
            ;;

        3)
            clear
            echo "You have selected option (3) to download a specific number of thumbnails in a given range. "
            get_dir #get directory to save file

            get_range #get the start and end value of the range
            
            temp=$((10#$end - 10#$start + 2))
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

            total_size=0 #total size of downloaded files in bytes
            total_count=0 #total number of downloaded files
            count=0 #count for the URL present 
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
            if (( "$total_count" > 1 )); then
                if (( "$total_count" >= 1048576 )); then
                    megabytes=$( echo $total_size | awk '{mb=$1/1048576; printf"%.2f\n", mb}' )
                    echo "$total_count files of total size $megabytes MB are downloaded."
                else
                    kilobytes=$( echo $total_size | awk '{kb=$1/1024; printf"%.2f\n", kb}' ) 
                    echo "$total_count files of total size $kilobytes KB are downloaded." 
                fi
            fi
            if (( "$count" == 0 )); then
                echo "No any thumbnail files found in the given range."
            elif (( "$count" < "$num" )); then
                echo "In the randomly selected $num files only $count files were found having valid URL."
            fi               
            ;;

        4)
            clear
            echo "You have selected option (4) to download all thumbnails."
            get_dir #get directory to save file

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
