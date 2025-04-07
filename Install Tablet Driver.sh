#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
sudo dnf install "https://github.com/OpenTabletDriver/OpenTabletDriver/releases/download/v0.6.5.1/opentabletdriver-0.6.5.1-1.x86_64.rpm"
echo "Rebuilding Initramfs (takes a while)"
sudo dracut --regenerate-all --force
udev_rule="/etc/udev/rules.d/99-opentabletdriver.rules"
if ! [ -f $udev_rule ]; then
  echo "Creating udev rule"
  echo "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"5543\", ATTRS{idProduct}==\"0062\", TAG+=\"uaccess\", TAG+=\"udev-acl\", MODE=\"0666\"" >> $udev_rule
  echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"5543\", ATTRS{idProduct}==\"0062\", TAG+=\"uaccess\", TAG+=\"udev-acl\", MODE=\"0666\"" >> $udev_rule
  echo "SUBSYSTEM==\"input\", ATTRS{idVendor}==\"5543\", ATTRS{idProduct}==\"0062\", ENV{LIBINPUT_IGNORE_DEVICE}=\"1\"" >> $udev_rule
fi
config_folder="/home/$SUDO_USER/.local/share/OpenTabletDriver/Configurations"
if ! [ -d $config_folder ]; then
  mkdir -p $config_folder 
fi
config_json='{
  "Name": "UC-LOGIC DrawImage EX05",
  "Specifications": {
    "Digitizer": {
      "Width": 204,
      "Height": 136,
      "MaxX": 32000,
      "MaxY": 21360
    },
    "Pen": {
      "MaxPressure": 2048,
      "Buttons": {
        "ButtonCount": 2
      }
    }
  },
  "DigitizerIdentifiers": [
    {
      "VendorID": 21827,
      "ProductID": 98,
      "InputReportLength": 8,
      "OutputReportLength": 0,
      "FeatureReportLength": 6,
      "ReportParser": "OpenTabletDriver.Configurations.Parsers.XP_Pen.XP_PenReportParser",
      "InitializationStrings": [
        100
      ]
    }
  ],
  "Attributes": {
    "libinputoverride": "1"
  }
}'
echo "Writing configuration json."
echo "$config_json" >> $config_folder/UGEE\ DrawImage\ EX05.json
sudo udevadm control --reload && sudo adevadm trigger
echo "Done."
