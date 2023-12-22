#!/bin/bash

## THE SCRIPT removes MX password policy.

FILE1=/etc/login.defs
FILE2=/etc/security/opasswd
FILE3=/etc/pam.d/system-auth

Help()
{
   # Display Help
   echo "Syntax: $(basename $BASH_SOURCE) [-c|-h]"
   echo "options:"
   echo "-c     Proceed with the changes."
   echo "-h     Print this help message."
   echo
}

if [[ ! $@ =~ ^\-.+ ]]
then
   echo "No options were passed. Please use -h parameter to get help."
fi

while getopts ":hc" option; do
   case ${option} in
      h ) # display Help
         Help
         exit;;

      c ) #proceed with changes

          echo "Changing $FILE1..."
          sed -i 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS 0/g' /etc/login.defs
          sed -i 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS 0/g' /etc/login.defs

          echo "Removing password history from $FILE2..."
          truncate -s 0 $FILE2

          echo "Skipping changing $FILE3..."
          exit;;


      \? ) # Invalid option
         echo "Error: Invalid option. Please use -h parameter to get help."
         exit 2;;

   esac
done



