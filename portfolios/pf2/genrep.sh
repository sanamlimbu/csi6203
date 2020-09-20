#!/bin/bash

#Name: Sanam Limbu
#Student ID: 10503270

start="<tr><td>"
end="<\/td><\/tr>"
mid="<\/td><td>"

# attacks.html file is read using cat and piped to grep command
# only lines containing <td> are grabbed and piped to sed
# using sed <tr><td> and </td></tr> are removed and </td><td> is replaced with space
# using awk totals of interger values of each records are calculated
# formatted results are printed to the terminal 
cat attacks.html | grep "<td>" | sed -e "s/^$start//g; s/$end$//g; s/$mid/ /g" | awk 'BEGIN {print "Attacks\t\tInstances(Q3)"} {total=($2+$3+$4); printf $1 "\t\t%d\n",total}'

exit 0 # successful execution