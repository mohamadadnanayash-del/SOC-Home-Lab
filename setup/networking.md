# Setup: Virtualization and Networking

## Host requirements

- Windows host, 16 GB RAM minimum (32 GB recommended), 4+ cores, ~150 GB free SSD
- CPU virtualization (VT-x / AMD-V) enabled in BIOS/UEFI
- VirtualBox 7.x and the matching Extension Pack

## Create the isolated network

Run in PowerShell on the host:

```powershell
$vbm = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

& $vbm natnetwork add --netname SOC-LAB --network "10.10.10.0/24" --enable --dhcp off
& $vbm natnetwork modify --netname SOC-LAB --port-forward-4 "wazuh-https:tcp:[127.0.0.1]:8443:[10.10.10.10]:443"
& $vbm natnetwork modify --netname SOC-LAB --port-forward-4 "wazuh-ssh:tcp:[127.0.0.1]:2222:[10.10.10.10]:22"

& $vbm natnetwork list
```

Every VM uses **Adapter 1 → NAT Network → SOC-LAB**.

## Address plan

| Host | IP |
|---|---|
| Gateway / DNS forwarder | 10.10.10.1 |
| soc-wazuh | 10.10.10.10 |
| WIN-ENDPOINT01 | 10.10.10.20 |
| kali-redteam | 10.10.10.30 |

## Verification

| Test | From | Expected |
|---|---|---|
| `ping 10.10.10.20` | Kali | Replies |
| `Test-NetConnection 10.10.10.10 -Port 1514` | Windows | `TcpTestSucceeded : True` |
| `https://127.0.0.1:8443` | Host browser | Wazuh login page |
| `ping 10.10.10.20` | Host | Fails (expected, the lab is isolated) |

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "VT-x is not available" | Enable virtualization in BIOS/UEFI |
| Slow VMs, turtle icon in the status bar | Hyper-V/VBS is active on the host. VirtualBox still works, just slower. |
| Port 8443 in use on the host | Pick another host port in the forward rule |
| VMs can't reach each other | Check that each adapter is attached to `SOC-LAB`, and recheck the static IPs |
