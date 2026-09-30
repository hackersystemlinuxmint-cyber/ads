import subprocess

def scan_wifi():
    # Execute the iwlist command to scan for WiFi networks
    data = subprocess.check_output(['iwlist', 'wlan0', 'scan']).decode('utf-8').split('\n')
    # Initialize an empty list to hold the network details
    networks = []
    # Iterate over each line in the output
    for line in data:
        # Check if the line contains a network's SSID
        if "ESSID" in line:
            # Extract the SSID
            ssid = line.split('"')[1]
            # Add the SSID to the list
            networks.append(ssid)
    return networks

# Run the function and print the list of nearby networks
nearby_networks = scan_wifi()
for network in nearby_networks:
    print(network)