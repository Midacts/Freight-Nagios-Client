#!/bin/bash
# Freight Repo Setup Script
# Date: 20th of May, 2014
# Version 1.0
#
# Author: John McCarthy
# Email: midactsmystery@gmail.com
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
function sources.list.d(){
	# Gets the address to reach the FPM/Frieght host by
		echo
		echo -e '\e[33mWhat is the best way for machines to reach Your Freight host ?\e[0m'
		echo -e '\e[30;01mMake sure machines can ping the Freight machine by this address\e[0m'
		read address

	# Creating the sources.list.d file and GPG file
		echo
		echo -e '\e[33mWhat would you like to name your sources.list.d file and GPG file ?\e[0m'
		echo -e '\e[33;01mFor Example: Type "example" to get example.list and example.gpg as filenames\e[0m'
		read filename
		echo "deb http://$address $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/$filename.list

	# Downloads the GPG file
		echo
		echo -e '\e[01;34m+++ Downloading your freight GPG key...\e[0m'
		wget -O /etc/apt/trusted.gpg.d/$filename.gpg http://$address/keyring.gpg

	# Update sources list
		apt-get update
		echo -e '\e[01;37;42mYour freight GPG key has been successfully downloaded!\e[0m'
}
function doAll()
{
	# Calls Function 'sources.list.d'
		echo -e "\e[33m=== Add your Freight Repo to your sources.list.d directory ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			sources.list.d
		fi

	# End of Script Congratulations, Farewell and Additional Information
		clear
		FARE=$(cat << EOZ


          \e[01;37;42mWell done! You have completed your Adding your Freight Repo! \e[0m

  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
EOZ
)

		#Calls the End of Script variable
		echo -e "$FARE"
		echo
		echo
		exit 0
}

# Check privileges
[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
clear
echo
echo
echo -e '               \e[01;37;42mWelcome to Midacts Mystery'\''s Freight Repo Script!\e[0m'
echo
echo
case "$go" in
        * )
                        doAll ;;
esac

exit 0
