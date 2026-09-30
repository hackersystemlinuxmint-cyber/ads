#!/usr/bin/env python3
"""
Bluetooth Connection Monitor with HTML Dashboard
Logs full info on any device connecting to YOUR adapter.
Authorized testing of your own device only.
"""
import bluetooth
import subprocess
import time
import json
import os
import html
from datetime import datetime

JSON_LOG = "bt_connections.json"
HTML_OUT = "bt_dashboard.html"
known = {}

def dump_json():
    with open(JSON_LOG, "w") as f:
        json.dump(known, f, indent=2)

def get_device_info(addr):
    info = {"mac": addr, "first_seen": datetime.now().isoformat()}
    try:
        info["name"] = bluetooth.lookup_name(addr, timeout=8)
    except Exception:
        info["name"] = None
    try:
        results = bluetooth.find_service(name=None, address=addr)
        info["services"] = [
            {"name": s.get("name"), "protocol": s.get("protocol"), "port": s.get("port")}
            for s in results
        ]
    except Exception:
        info["services"] = []
    return info

def get_system_bt_devices():
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
                out += [{"mac": d.get("InstanceId"),
                         "name": d.get("FriendlyName")} for d in data]
        else:
            r = subprocess.run(["bluetoothctl", "devices", "Connected"],
                               capture_output=True, text=True, timeout=15)
            for line in r.stdout.splitlines():
                if line.startswith("Device "):
                    _, mac, *name = line.split()
                    out.append({"mac": mac, "name": " ".join(name)})
    except Exception:
        pass
    return out

def build_html():
    rows = ""
    for mac, d in known.items():
        svcs = ", ".join(
            html.escape(f"{s.get('name')} ({s.get('protocol')}:{s.get('port')})")
            for s in d.get("services", []) if s.get("name")
        ) or "None detected"
        rows += f"""
        <tr>
          <td>{html.escape(str(d.get('name') or 'Unknown'))}</td>
          <td>{html.escape(mac)}</td>
          <td>{html.escape(d.get('first_seen', ''))}</td>
          <td>{svcs}</td>
        </tr>"""
    total = len(known)
    page = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>BT Monitor Dashboard</title>
<meta http-equiv="refresh" content="5">
<style>
  body {{ background:#0d1117; color:#c9d1d9; font-family:Segoe UI,Arial,sans-serif;
         margin:0; padding:24px; }}
  h1 {{ color:#58a6ff; font-size:22px; }}
  .stat {{ display:inline-block; background:#161b22; border:1px solid #30363d;
          border-radius:8px; padding:12px 20px; margin-right:12px; }}
  .stat b {{ color:#3fb950; font-size:26px; display:block; }}
  table {{ border-collapse:collapse; width:100%; margin-top:20px;
           background:#161b22; border-radius:8px; overflow:hidden; }}
  th {{ background:#21262d; color:#58a6ff; text-align:left; padding:10px; }}
  td {{ border-top:1px solid #30363d; padding:10px; }}
  tr:hover td {{ background:#1c2128; }}
  .upd {{ color:#8b949e; font-size:12px; margin-top:8px; }}
</style>
</head>
<body>
  <h1>Bluetooth Connection Monitor</h1>
  <div class="stat"><b>{total}</b>Devices Connected (total seen)</div>
  <table>
    <tr><th>Name</th><th>MAC / Instance</th><th>First Seen</th><th>Services</th></tr>
    {rows if rows else '<tr><td colspan="4">No devices detected yet…</td></tr>'}
  </table>
  <div class="upd">Auto-refreshes every 5s &middot; Last built: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</div>
</body>
</html>"""
    with open(HTML_OUT, "w", encoding="utf-8") as f:
        f.write(page)

def main():
    print(f"[*] Monitoring. Open {HTML_OUT} in your browser.")
    while True:
        for d in get_system_bt_devices():
            mac = d.get("mac", "unknown")
            if mac not in known:
                print(f"[+] NEW: {d.get('name')} [{mac}]")
                info = get_device_info(mac)
                info.update(d)
                known[mac] = info
                dump_json()
        build_html()
        time.sleep(5)

if __name__ == "__main__":
    main()
