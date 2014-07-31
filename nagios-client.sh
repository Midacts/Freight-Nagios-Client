#!/bin/bash
# FPM Packaging with Freight Hosting Script for Nagios Clients
# Date: 31st of July, 2014
# Version 1.1
#
# Author: John McCarthy
# Email: midactsmystery@gmail.com
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
######## VARIABLES ########
plugin_version=2.0.3
nrpe_version=2.15
function nagios-plugins(){
	# Install the prerequisite packages for Nagios Plugins
		echo
		echo -e '\e[01;34m+++ Installing the prerequisite software...\e[0m'
		apt-get update
		apt-get install -y build-essential libgd2-xpm-dev libssl-dev
		echo -e '\e[01;37;42mThe prerequisite software has been successfully installed!\e[0m'

	# Downloaded the latest Nagios Plugins files
		echo
		echo -e '\e[01;34m+++ Downloading the latest Nagios Plugins files...\e[0m'
		cd
		wget https://www.nagios-plugins.org/download/nagios-plugins-$plugin_version.tar.gz

	# Extract the NRPE Plugin
		tar xzf nagios-plugins-$plugin_version.tar.gz
		cd nagios-plugins-$plugin_version
		echo -e '\e[01;37;42mThe latest Nagios Plugins files have been successfully downloaded!\e[0m'

	# Configure the installation
		echo
		echo -e '\e[01;34m+++ Configuring the Nagios Plugins installation files...\e[0m'
		groupadd -g 9000 nagios
		useradd -u 9000 -g nagios -d /usr/local/nagios -c 'Nagios Admin' nagios
		./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules --enable-libtap
		make

	# Create the directories to house the installation files
		mkdir /tmp/installdir/nagios-plugins

	# Makes the installation file
		make install DESTDIR=/tmp/installdir/nagios-plugins
		echo -e '\e[01;37;42mThe Nagios Plugin installation files have been configured!\e[0m'

	# Create the --after-installation script for Nagios Plugins
		cat << 'EOP' > /root/plugins.sh
#!/bin/bash
# Set Folder Permissions
	useradd nagios
	chown nagios:nagios /usr/local/nagios
	chown -R nagios:nagios /usr/local/nagios/libexec

EOP

	# Use FPM to make the .deb Nagios Plugins package
		echo
		echo -e '\e[01;34m+++ Creating the Nagios Plugins package...\e[0m'
		echo
		fpm -s dir -t deb -n nagios-plugins-client -v $plugin_version -d "nrpe-client (>= 2.15)" -d "libssl-dev (>= 1.0.1e-2+deb7u7)" --after-install /root/plugins.sh -C /tmp/installdir/nagios-plugins usr

	# Move the Nagios Plugins package to the root directory
		mv nagios-plugins-client_"$plugin_version"_amd64.deb /root
		echo
		echo -e '\e[01;37;42mThe Nagios Plugins package has been successfully created!\e[0m'
}
function nrpe(){
	# Download the latest nrpe files
		echo
		echo -e '\e[01;34m+++ Downloading the latest nrpe files...\e[0m'
		cd
		wget http://sourceforge.net/projects/nagios/files/nrpe-$nrpe_version.tar.gz

	# Untar the nrpe files
		tar xzf nrpe-$nrpe_version.tar.gz
		cd nrpe-$nrpe_version
		echo -e '\e[01;37;42mThe latest nrpe files have been successfully downloaded!\e[0m'

	# Configure the nrpe installation
		echo
		echo -e '\e[01;34m+++ Configuring the nrpe installation files...\e[0m'
		./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
		make
		make all

	# Create the directory to house the install
		mkdir -p /tmp/installdir/nrpe/etc/init.d/

	# Makes the installtion files
		make install DESTDIR=/tmp/installdir/nrpe
		make install-plugin DESTDIR=/tmp/installdir/nrpe
		make install-daemon DESTDIR=/tmp/installdir/nrpe
		make install-daemon-config DESTDIR=/tmp/installdir/nrpe

	# Copies over the nrpe init scripts and makes it executable
		cp init-script.debian /tmp/installdir/nrpe/etc/init.d/nrpe
		chmod 700 /tmp/installdir/nrpe/etc/init.d/nrpe
		echo -e '\e[01;37;42mThe nrpe installation files have been configured!\e[0m'

	# Create the --after-installation script for nrpe
		cat << 'EOR' > /root/nrpe.sh
#!/bin/bash
	# Starting nrpe at boot time
		update-rc.d nrpe defaults

EOR

	# Use FPM to make the .deb nrpe package
		echo
		echo -e '\e[01;34m+++ Creating the nrpe package...\e[0m'
		echo
		fpm -s dir -t deb -n nrpe-client -v $nrpe_version -d "nagios-plugins-client (>=2.0.1)" -C /tmp/installdir/nrpe usr etc

	# Move the Nagios Plugins package to the root directory
		mv nrpe-client_"$nrpe_version"_amd64.deb /root
		echo
		echo -e '\e[01;37;42mThe nrpe package has been successfully created!\e[0m'

}
function freight(){
	# Finds the Nagios Plugins package
		plugins_file=$(find -name "nagios-plugins-client_*")
		plugins=$(echo $plugins_file | awk '{$0=substr($0,3,length($0)); print $0}')

	# Finds the nrpe package
		nrpe_file=$(find -name "nrpe-client_$nrpe_version*")
		nrpe=$(echo $nrpe_file | awk '{$0=substr($0,3,length($0)); print $0}')

	# Adding your FPM packages to your freight repo
		echo
		echo -e '\e[33mWhat repo do you want to put these files in ?\e[0m'
		echo -e '\e[31m  Please put a space beteen each repo\e[0m'
		echo -e '\e[33;01mFor example: apt/squeeze apt/wheezy apt/trusty\e[0m'
		read -ra repo
		/usr/bin/freight add $plugins $nrpe ${repo[0]} ${repo[1]} ${repo[2]} ${repo[3]} ${repo[4]}
		echo
		echo -e '\e[30;01mPlease type in your GPG Key passphrase for as many repos you are adding\e[0m'
		echo
		/usr/bin/freight cache
}
function doAll(){
	# Calls Function 'nagios-plugins'
		echo
		echo
		echo -e "\e[33m=== Package Nagios Plugins ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			nagios-plugins
		fi

	# Calls Function 'nrpe'
		echo
		echo -e "\e[33m=== Package nrpe ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			nrpe
		fi

	# Calls Function 'freight'
		echo
		echo -e "\e[33m=== Add these packages to your Freight repo ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			freight
		fi

	# End of Script Congratulations, Farewell and Additional Information
		clear
		farewell=$(cat << EOZ


\e[01;37;42mWell done! You have created your FPM package and hosted it on your Freight repo!\e[0m

  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
EOZ
)

		#Calls the End of Script variable
		echo -e "$farewell"
		echo
		echo
		exit 0
}

# Check privileges
	[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	clear
	welcome=$(cat << EOA


     \e[01;37;42mWelcome to Midacts Mystery's FPM Packaging and Freight Hosting Script!\e[0m
EOA
)

# Calls the welcome variable
	echo -e "$welcome"

# Calls the doAll function
	case "$go" in
		* )
			doAll ;;
	esac

# Exits the script
	exit 0
