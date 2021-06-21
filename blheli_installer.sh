#!/bin/sh

# Remove old
rm -rf ~/.local/share/applications/blheli-configurator.desktop
sudo rm -rf /opt/blheli

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
echo -e "\nType the port you want to setup BLHeli (ex: /dev/ttyACM0) : "
read ttyPort

# Download BLHeli
wget https://github.com/blheli-configurator/blheli-configurator/releases/download/1.2.0/BLHeli-Configurator_linux64_1.2.0.zip

# Extract BF
unzip BLHeli-Configurator_*

# Move to /opt
sudo cp -r BLHeli\ Configurator /opt/blheli

# Download icon
sudo mkdir /opt/blheli/icon
sudo wget -O /opt/blheli/icon/blheli_icon_128.png https://raw.githubusercontent.com/blheli-configurator/blheli-configurator/master/images/icon_128.png

# Create a Launcher to .local/share/applications
cat >> ~/.local/share/applications/blheli-configurator.desktop << EOL
[Desktop Entry]
Name=BLHeli Configurator
Comment=Crossplatform configuration tool for the BLHeli ESC control system
Exec=/opt/blheli/run.sh
Icon=/opt/blheli/icon/blheli_icon_128.png
Type=Application
Categories=Utility
EOL
sudo chmod +x ~/.local/share/applications/blheli-configurator.desktop

# Create a running script for port permissions
BL_DIR=/opt/blheli/run.sh
sudo touch $BL_DIR

sudo sh -c "echo \#! /bin/sh > $BL_DIR"
sudo sh -c "echo cd /opt/blheli >> $BL_DIR"
sudo sh -c "echo '\$TERMINAL' -e sh -c \'sudo chmod 777 $ttyPort\' >> $BL_DIR"
sudo sh -c "echo ./blheli-configurator >> $BL_DIR"

sudo chmod +x $BL_DIR

# Clean
rm -rf BLHeli\ Configurator
rm -rf BLHeli-Configurator_*

# Finished
echo -e "\n***** FINISHED ! ******\n"
