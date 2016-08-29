#!/bin/bash
#title          :rtc.sh
#description    :This script is to sync RTC Time with the System Time and Vice Versa.
#author         :Bruno Fernandes {brunof@fe.up.pt, 1080557@isep.ipp.pt}
#date           :29-08-2016
#version        :1
#usage          :sudo ./rtc.sh
#notes          : I only dedicated a couple of hours for this. A lot of validations are needed.
#==============================================================================

INTERNET="www.google.com"

# Checks internet connection and if i2c-tools package is installed, if not, forces installation
verify() {
	local pkg="i2c-tools"
	if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		echo "No $pkg installed. Setting it up."
		if [ $(sudo ping -c 2 $INTERNET > /dev/null 2>&1; echo $?) -eq 0 ]; then
			$(sudo apt-get update && sudo apt-get --force-yes --yes install $pkg)
		else
			echo "No internet Access! Please ensure you have internet access to install $pkg."
			exit $?
		fi
		if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
			echo "The $pkg was installed successfully."
		fi
	fi
}

# Detect if I2C RTC device address is valid
get_RTC_addr() {
	i2c_rtc=$(sudo i2cdetect -y 1)
	if echo "$i2c_rtc" | grep -q "68"; then
		echo "Address: 0x68";
	elif echo "$i2c_rtc" | grep -q "UU"; then
		echo "Address: 0xUU Reseting the kernel modules...";
		sudo rmmod i2c-bcm2708 && sudo modprobe i2c-bcm2708 # Reset I2C Bus when adress is 0xUU or Invalid
		echo "Done!"
		echo "Verifying RTC I2C Address again..."
		i2c_rtc=$(sudo i2cdetect -y 1)
		if echo "$i2c_rtc" | grep -q "68"; then
			echo "Address: 0x68";
		elif echo "$i2c_rtc" | grep -q "UU"; then
			echo "Address: 0xUU";
		else
			echo "No device was found!"
		fi
	else
		echo "Invalid Address or no device found.";
	fi
}

#Call the above functions
verify
get_RTC_addr

# Create as super user the device file
sudo su -c "sudo echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device"

# Restart the NTP service to force a sync with NTP servers
sudo service ntp restart

if [ $(sudo ping -c 4 $INTERNET > /dev/null 2>&1; echo $?) -eq 0 ]; then
        # Set the RTC time to the current system time
        sudo hwclock --systohc --utc # Choose "--localtime" option for localtime
        echo "Set RTC Time from System Time";
	sudo date; sudo hwclock -r; # Show System Time and RTC Time
	exit $?
else
        # Set the system time from the RTC
        sudo hwclock --hctosys --utc # Choose "--localtime" option for localtime
        echo "Set System Time from RTC Time";
	sudo date; sudo hwclock -r; # Show System Time and RTC Time
	exit $?
fi