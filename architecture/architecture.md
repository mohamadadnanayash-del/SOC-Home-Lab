# Lab Architecture

## Overview

The lab is three virtual machines on one isolated VirtualBox NAT Network. A Windows 11 endpoint generates telemetry (Sysmon, Security, PowerShell, Task Scheduler, Defender), a Wazuh agent ships it to a dedicated SIEM VM, and a Kali VM provides a separate, attributable source for controlled test activity.

Logs leave the endpoint as soon as they're written, so evidence survives on the SIEM even if the endpoint is treated as compromised.

## Diagram

```
                        ┌──────────────────────────────────────────┐
                        │        PHYSICAL HOST (Windows laptop)    │
                        │  VirtualBox  |  Browser → 127.0.0.1:8443 │
                        └───────────────────┬──────────────────────┘
                                            │ port-forward (dashboard + SSH only, bound to localhost)
 ┌──────────────────────────────────────────┼──────────────────────────────────┐
 │           ISOLATED NAT NETWORK  "SOC-LAB"   10.10.10.0/24                   │
 │                                          │                                  │
 │  ┌──────────────────┐            ┌───────┴──────────────────────────┐       │
 │  │  KALI LINUX      │  test      │   SIEM  (soc-wazuh)              │       │
 │  │  kali-redteam    │  activity  │   Ubuntu 24.04 · 10.10.10.10     │       │
 │  │  10.10.10.30     ├──────┐     │  ┌────────────────────────────┐  │       │
 │  └──────────────────┘      │     │  │ Wazuh Manager              │  │       │
 │                            │     │  │  • Decoders / rules        │  │       │
 │                            ▼     │  │  • soc_lab_rules.xml       │  │       │
 │  ┌─────────────────────────────┐ │  │  • MITRE ATT&CK tagging    │  │       │
 │  │ WINDOWS 11 (WIN-ENDPOINT01) │ │  ├────────────────────────────┤  │       │
 │  │ 10.10.10.20                 │ │  │ Wazuh Indexer              │  │       │
 │  │                             │ │  │  alerts + archives indices │  │       │
 │  │ Sysmon                      │ │  ├────────────────────────────┤  │       │
 │  │ Security / System logs      │ │  │ Wazuh Dashboard (443)      │  │       │
 │  │ PowerShell 4103/4104        │ │  └────────────────────────────┘  │       │
 │  │ Task Scheduler / Defender   │ └───────────────▲──────────────────┘       │
 │  │ FIM (C:\LabData, Startup)   │                 │                          │
 │  │         │                   │   1514/TCP      │                          │
 │  │   Wazuh Agent ──────────────┼─────────────────┘                          │
 │  └─────────────────────────────┘   1515/TCP (enrollment)                    │
 └─────────────────────────────────────────────────────────────────────────────┘
```

## Hosts

| Hostname | Role | OS | IP | vCPU / RAM / Disk |
|---|---|---|---|---|
| `soc-wazuh` | SIEM (Wazuh 4.14 all-in-one) | Ubuntu Server 24.04 LTS | 10.10.10.10 | 4 / 8 GB / 60 GB |
| `WIN-ENDPOINT01` | Monitored endpoint | Windows 11 Enterprise (eval) | 10.10.10.20 | 2 / 4 GB / 64 GB |
| `kali-redteam` | Test activity source | Kali Linux | 10.10.10.30 | 2 / 2-4 GB / 40 GB |

Gateway and DNS forwarder: `10.10.10.1` (VirtualBox NAT). DHCP is disabled and all addresses are static so indicators stay consistent across investigations.

## Ports

| Port | Direction | Purpose |
|---|---|---|
| 1514/TCP | Agent → Manager | Encrypted event forwarding |
| 1515/TCP | Agent → Manager | Agent enrollment |
| 443/TCP | Analyst → Dashboard | Web UI (forwarded to `127.0.0.1:8443` on the host) |
| 22/TCP | Analyst → SIEM | SSH (forwarded to `127.0.0.1:2222` on the host) |
| 55000/TCP | Dashboard → Manager | Wazuh API (local) |

## Data flow

1. **Generation:** Sysmon, the Windows Security/System logs, PowerShell Operational, Task Scheduler Operational and Defender Operational record activity on the endpoint. Wazuh FIM watches selected folders.
2. **Collection:** The Wazuh agent reads those channels (configured centrally in `configs/agent.conf`) and forwards events over 1514/TCP.
3. **Analysis:** The manager decodes events, runs the built-in ruleset plus `detections/rules/soc_lab_rules.xml`, and tags matches with MITRE ATT&CK IDs.
4. **Storage:** Rule matches go to `wazuh-alerts-*`. Every event, matched or not, goes to `wazuh-archives-*` for threat hunting.
5. **Analysis and response:** Alerts are triaged in the dashboard, investigated, and written up in `investigations/` and `incident-response/`.

## Isolation controls

- NAT Network only. No bridged adapters, so the lab isn't reachable from the home LAN.
- Host port-forwards are bound to `127.0.0.1`.
- All test activity targets `10.10.10.0/24` only.
- Snapshots are taken before every simulation and restored afterwards.
