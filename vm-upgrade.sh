#!/bin/bash
FILE1=/usr/bin/vmware-toolbox-cmd
FILE2=/usr/bin/vmware-toolbox-cmd.back

Help()
{
   # Display Help
   echo "Syntax: $(basename $BASH_SOURCE) [-c|-r|-h]"
   echo "options:"
   echo "-c     Crack the system to upgrade Imperva Securesphere."
   echo "-r     Revert the system to the previos state."
   echo "-h     Print this help message."
   echo
}

if [[ ! $@ =~ ^\-.+ ]]
then
   echo "No options were passed. Please use -h parameter to get help."
fi

while getopts ":hcr" option; do
   case ${option} in
      h ) # display Help
         Help
         exit;;

      c ) #crack the system
	  if test -f "$FILE2"; then
             echo "The crack has been already applied."
          else
             echo "Preparing system to successful upgrade..."
             mv "$FILE1" "$FILE2"
             echo '#!/bin/bash' > "$FILE1"
             echo 'echo "0"' >> "$FILE1"
             chmod +x "$FILE1"
             echo "DONE! System cracked! Dont forget to restore the system after the upgrade is done."
          fi
	  exit;;

      r ) #restore the system
	if test -f "$FILE2"; then
	    echo "Restoring the system..."
	    rm -f "$FILE1"
	    mv "$FILE2" "$FILE1"
	    echo "DONE! System restored!"
	else
	    echo "The crack has not been yet applied."
	fi
	exit;;

      \? ) # Invalid option
         echo "Error: Invalid option. Please use -h parameter to get help."
         exit 2;;

   esac
done


