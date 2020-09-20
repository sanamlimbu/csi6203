#!/bin/bash

read -p "Enter pattern :" pattern

grep  -w $pattern access_log.txt

exit 0