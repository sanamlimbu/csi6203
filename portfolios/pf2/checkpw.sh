#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

#leave header of the file, header has NR=0 
awk 'NR>1{
        #second field in the record is password                              
        password=$2                    
        if ( length(password) >= 8 &&   #password length >= 8
            password ~ /[0-9]/ &&       #password contains atleast 1 number
            password ~ /[A-Z]/){        #password contains atleast 1 uppercase letter
              printf "%s - meets password strength requirements\n", password
            }
        else{
                printf "%s - does NOT meet password strength requirements\n", password
        }
    }' usrpwords.txt 

exit 0 #successful execution