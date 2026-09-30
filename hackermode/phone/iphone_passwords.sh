#!/bin/bash

# Mount iPhone file system
MOUNT_POINT="/tmp/iphone_mount"
mkdir -p $MOUNT_POINT
idevicepair pair > /dev/null 2>&1
ifuse $MOUNT_POINT

echo "Starting extraction..." > extracted_iphone_data.txt

# Get Device Name
DEVICE_NAME=$(ideviceinfo --key DeviceName)
echo "Device Name: $DEVICE_NAME" >> extracted_iphone_data.txt

# Get Wi-Fi Passwords (stored in Preferences domain)
echo "Wi-Fi Passwords:" >> extracted_iphone_data.txt
cat "$MOUNT_POINT/Library/Preferences/com.apple.wifi.plist" 2>/dev/null | grep -A2 -B2 "SSID" >> extracted_iphone_data.txt

# Get Keychain Items (requires jailbreak or specific tools)
echo "Keychain Items (Partial):" >> extracted_iphone_data.txt
cat "$MOUNT_POINT/Library/Keychains/*" 2>/dev/null | strings | grep -E "password|Password" >> extracted_iphone_data.txt

# Unmount
umount $MOUNT_POINT
rm -rf $MOUNT_POINT

echo "Extraction complete. Check extracted_iphone_data.txt"