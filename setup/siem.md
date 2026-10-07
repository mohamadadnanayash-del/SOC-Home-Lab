# Setup: Wazuh SIEM (Ubuntu Server 24.04)

## VM

`soc-wazuh`: 4 vCPU, 8 GB RAM, 60 GB disk, NAT Network `SOC-LAB`, static IP `10.10.10.10/24`, gateway `10.10.10.1`.

If the IP wasn't set in the installer, configure netplan:

```yaml
# /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [10.10.10.10/24]
      routes:
        - to: default
          via: 10.10.10.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

```bash
sudo chmod 600 /etc/netplan/*.yaml && sudo netplan apply
```

## Base config

```bash
sudo apt update && sudo apt -y upgrade
sudo timedatectl set-timezone Asia/Dubai
sudo apt -y install curl tar net-tools
```

The timezone is set to match the endpoint so incident timelines line up.

## Install Wazuh 4.14 (all-in-one)

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

The admin password is printed at the end of the install. To recover it later:

```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

## Verify

```bash
sudo systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard
sudo ss -tlnp | grep -E ":443|:1514|:1515|:55000"
```

The dashboard is reachable from the host at `https://127.0.0.1:8443`.

## Archives for threat hunting

By default Wazuh only indexes events that match a rule. To hunt across raw telemetry:

```bash
sudo sed -i 's|<logall_json>no</logall_json>|<logall_json>yes</logall_json>|' /var/ossec/etc/ossec.conf
# /etc/filebeat/filebeat.yml -> archives: enabled: true
sudo systemctl restart filebeat wazuh-manager
```

Then create the index pattern `wazuh-archives-*` (timestamp field `timestamp`) under Dashboards Management → Index patterns.

## Centralized agent configuration

Endpoint log sources and FIM are pushed from the manager through the `default` agent group, so endpoints don't need local edits:

```bash
sudo cp configs/agent.conf /var/ossec/etc/shared/default/agent.conf
sudo chown wazuh:wazuh /var/ossec/etc/shared/default/agent.conf
sudo /var/ossec/bin/verify-agent-conf
```

## Custom rules

```bash
sudo cp detections/rules/soc_lab_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/soc_lab_rules.xml
sudo chmod 660 /var/ossec/etc/rules/soc_lab_rules.xml
sudo /var/ossec/bin/wazuh-analysisd -t && sudo systemctl restart wazuh-manager
```

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Installer aborts on hardware check | Give the VM at least 4 GB RAM (8 GB recommended) |
| "already installed" on re-run | Rerun with `-a -o` to overwrite |
| "Dashboard server is not ready yet" | The indexer is still starting. Wait 2-3 minutes. |
| Indexer fails after reboot | `journalctl -u wazuh-indexer -n 50`. Usually low RAM or a full disk (`df -h`). |
| Duplicate agent name after a snapshot revert | `manage_agents -l`, then `manage_agents -r <id>`, then restart the agent |
