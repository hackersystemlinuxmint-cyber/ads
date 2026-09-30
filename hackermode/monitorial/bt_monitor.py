#!/usr/bin/env python3
"""
Bluetooth Connection Monitor - logs full info on any device
that connects to YOUR adapter. Authorized testing of your own device.
"""
import bluetooth
import subprocess
import time
import json
import os
from datetime import datetime

LOG = "bt_connections.log"
JSON_LOG = "bt_connections.json"
known = {}

def log(msg):
    line = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}"
    print(line)
    with open(LOG, "a") as f:
        f.write(line + "\n")

def dump_json():
    with open(JSON_LOG, "w") as f:
        json.dump(known, f, indent=2)

def get_device_info(addr):
    """Enumerate everything readable from a connected device."""
    info = {"mac": addr, "first_seen": datetime.now().isoformat()}
    try:
        name = bluetooth.lookup_name(addr, timeout=8)
        info["name"] = name
    except Exception:
        info["name"] = None
    # Device class / type
    try:
        results = bluetooth.find_service(name=None, address=addr)
        info["services"] = [
            {"name": s.get("name"), "protocol": s.get("protocol"),
             "port": s.get("port"), "service_id": s.get("service-id")}
            for s in results
        ]
    except Exception:
        info["services"] = []
    return info

def get_system_bt_devices():
    """Cross-platform: list currently connected BT devices via OS tools."""
    out = []
    try:
        if os.name == "nt":
            r = subprocess.run(
                ["powershell", "-NoProfile", "-Command",
                 "Get-PnpDevice -Class Bluetooth -Status OK | "
                 "Select-Object FriendlyName, InstanceId | ConvertTo-Json"],
                capture_output=True, text=True, timeout=15)
            if r.stdout.strip():
                data = json.loads(r.stdout)
                if isinstance(data, dict): data = [data]
                out += [{"name": d.get("FriendlyName"),
                         "instance": d.get("InstanceId")} for d in data]
        else:
            r = subprocess.run(["bluetoothctl", "devices", "Connected"],
                               capture_output=True, text=True, timeout=15)
            for line in r.stdout.splitlines():
                if line.startswith("Device "):
                    _, mac, *name = line.split()
                    out.append({"mac": mac, "name": " ".join(name)})
    except Exception as e:
        log(f"OS enumeration error: {e}")
    return out

def main():
    log("=== Bluetooth monitor started ===")
    while True:
        devices = get_system_bt_devices()
        for d in devices:
            mac = d.get("mac") or d.get("instance", "unknown")
            if mac not in known:
                log(f"NEW CONNECTION: {d.get('name', 'unnamed')} [{mac}]")
                info = get_device_info(mac)
                info.update(d)
                known[mac] = info
                log(f"  Full info: {json.dumps(info)}")
                dump_json()
            else:
                # Already known, just note still connected
                pass
        if not devices:
            pass  # nothing connected right
