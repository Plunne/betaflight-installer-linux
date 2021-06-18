#!/bin/sh

# Display connected ports with device name
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && exit
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && exit
        echo "/dev/$devname - $ID_SERIAL"
    )
done

# Insert the port
echo -e "\nType the port you want to setup BF (ex: /dev/ttyACM0) : "
read ttyPort

# Download BF
wget https://github.com/betaflight/betaflight-configurator/releases/download/10.7.0/betaflight-configurator_10.7.0_linux64.zip

# Extract BF
unzip betaflight-configurator_*

# Move to /opt
sudo mkdir /opt/betaflight
sudo cp -r Betaflight\ Configurator /opt/betaflight/betaflight-configurator

# Create a Launcher to .local/share/applications
cat >> ~/.local/share/applications/betaflight-configurator.desktop << EOL
[Desktop Entry]
Name=Betaflight Configurator
Comment=Crossplatform configuration tool for the Betaflight flight control system
Exec=/opt/betaflight/betaflight-configurator/run.sh
Icon=/opt/betaflight/betaflight-configurator/icon/bf_icon_128.png
Type=Application
Categories=Utility
EOL
sudo chmod +x ~/.local/share/applications/betaflight-configurator.desktop

# Create a running script for port permissions
BF_DIR=/opt/betaflight/betaflight-configurator/run.sh
sudo touch $BF_DIR

sudo sh -c "echo \#! /bin/sh > $BF_DIR"
sudo sh -c "echo cd /opt/betaflight/betaflight-configurator >> $BF_DIR"
sudo sh -c "echo '\$TERMINAL' -e sh -c \'sudo chmod 777 $ttyPort\' >> $BF_DIR"
sudo sh -c "echo ./betaflight-configurator >> $BF_DIR"

sudo chmod +x $BF_DIR

# Clean
rm -rf Betaflight\ Configurator
rm -rf betaflight-configurator_10.7.0_linux64.zip

# Finished
echo -e "\n***** FINISHED ! ******\n"
