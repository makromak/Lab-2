# Lab 2 — A Windows guest, and a network between them

- **Pair:** Kazhymurat / Arsen
- **Driver first half:** Kazhymurat
- **Machine:** Kazhymurat's laptop (my pair partner; I work on a Mac), AMD Ryzen 9 8940HX (16 cores / 32 threads), 32 GB RAM (31.2 GB usable), Windows host, VirtualBox. Guests: Ubuntu Server 26.04 LTS + Windows 11 Enterprise (evaluation)
- **Date:** 29.10.2026

## What I did

Steps, with commands in code blocks.

### 1. Get the ISO and check the licence

Windows 11 Enterprise evaluation (free, 90 days) from the Microsoft Evaluation Center:(https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise). I did not type any product key.

```
slmgr.vbs /xpr
Windows(R), EnterpriseEval edition:
    Timebased activation will expire 1/27/2027 3:13:33 AM
```

### 2. Create the Windows VM

VirtualBox name: `VM2`. Settings: 4 vCPU, 4096 MB RAM, 64 GB disk (dynamically allocated), EFI + Secure Boot, TPM 2.0 (checked in Settings → System).

### 3. Install Windows

VirtualBox installed Windows by itself (see "What did not work the first time"). Checked the result:

```
winver
Windows 11 Enterprise Evaluation
```

### 4. Put both guests on one network

Mode: **NAT Network** (`NatNetwork`), on both VMs.

```
File → Tools → Network Manager → NAT Networks → Create
Each VM: Settings → Network → Adapter 1 → Attached to: NAT Network → NatNetwork
```

Why: both guests must see each other and the internet. Plain NAT gives each VM its own private router, so the guests cannot see each other. Host-only has no internet. Bridged can be blocked on campus Wi-Fi (I did not try it).

### 5. Find both addresses

```
# Ubuntu
$ ip -br a
lo      UNKNOWN   127.0.0.1/8 ::1/128
enp0s3  UP        10.0.2.3/24 ...

# Windows (PowerShell)
PS> ipconfig
IPv4 Address. . . . : 10.0.2.4
Subnet Mask . . . . : 255.255.255.0
Default Gateway . . : 10.0.2.1
```

### 6. Ping both ways and fix the firewall

Windows → Ubuntu works at once (Ubuntu's firewall is off by default):

```
PS> ping 10.0.2.3
Reply from 10.0.2.3: bytes=32 time<1ms TTL=64   (x4)
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)
```

Ubuntu → Windows, before the firewall rule:

```
$ ping -c 4 10.0.2.4
PING 10.0.2.4 (10.0.2.4) 56(84) bytes of data.

--- 10.0.2.4 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 4115ms
```

Why it times out: ping sends ICMP echo requests, and Windows Defender Firewall blocks incoming echo requests by default.

Fix: one rule that allows only ping (PowerShell as Administrator). The firewall stays on.

```
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

Ubuntu → Windows after the rule, and the internet from both guests:

```
$ ping -c 4 10.0.2.4
4 packets transmitted, 4 received, 0% packet loss
$ ping -c 4 ubuntu.com
4 packets transmitted, 4 received, 0% packet loss
PS> ping ubuntu.com
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)
```

### 7. Save the evidence on the laptop

On a NAT Network the host cannot reach a guest directly, so I added a port forwarding rule: host port `2222` → Ubuntu `10.0.2.3:22` (File → Tools → Network Manager → NAT Networks → NatNetwork → Port Forwarding). Output from Windows was sent to Ubuntu over the network, then fetched from the laptop.

```
ssh -p 2222 kash@127.0.0.1 "ip addr" | Out-File -Encoding utf8 evidence/ip-addr-linux.txt
ipconfig | ssh kash@10.0.2.3 "cat > ipconfig-windows.txt"        # run inside Windows
ssh -p 2222 kash@127.0.0.1 "cat ipconfig-windows.txt" | Out-File -Encoding utf8 evidence/ipconfig-windows.txt
```

`ping-both-ways.txt` was made the same way (four pings, each under a short heading).

### 8. Overcommit the memory

Both guests set to 20480 MB (20 GB + 20 GB = 40 GB promised) on a host with 31.2 GB. Started both, opened a browser in Windows, ran `sudo apt update` in Ubuntu, then looked at the host in Task Manager → Performance → Memory (before and after).

```
Each VM: Settings → System → Base Memory = 20480 MB
```

Afterwards I set the memory back: Ubuntu 4096 MB, Windows 4096 MB.

## Network diagram

```
                 Internet
                    |
        Host laptop (Windows, Wi-Fi)
                    |
 [VirtualBox NAT Network "NatNetwork" · 10.0.2.0/24 · gateway 10.0.2.1]
          /                                   \
   ubuntu-serverr                        VM2 (Windows 11 Enterprise eval)
   10.0.2.3                              10.0.2.4

 SSH from the host: 127.0.0.1:2222 --(port forwarding)--> 10.0.2.3:22
```

## Result

| | Before | After |
|---|---|---|
| Host RAM in use | 8 GB | 27.2 GB |
| Available | 23.2 GB | 4.0 GB |
| Committed / Swap used | 15.2 / 33.2 GB | 34.5 / 35.2 GB (committed) |
| What I noticed | — | No freezing and no stuttering. Available memory fell to 4.0 GB and committed memory came close to its limit. |

Both guests see each other and the internet, ping works both ways with a firewall rule that allows only ping, and the host stayed responsive with 40 GB promised on a 31.2 GB laptop.

## What did not work the first time

1. **`ping: command not found` on Ubuntu.**
   - I saw: the Ubuntu → Windows ping did not start at all.
   - It turned out to be: the minimized Ubuntu Server image has no `ping` tool.
   - I did: `sudo apt update` and `sudo apt install -y iputils-ping`.

2. **Windows installed itself.**
   - I saw: after the first boot Windows went straight to the desktop with no setup screens, and the user was `vboxuser`.
   - It turned out to be: VirtualBox ran its unattended installation even though "Skip Unattended Installation" was ticked. I do not know why.
   - I did: kept the VM, because the edition and the licence were correct (checked with `winver` and `slmgr.vbs /xpr`).

3. **"Windows License is expired" on the desktop.**
   - I saw: this watermark in the corner right after the install.
   - It turned out to be: `slmgr.vbs /xpr` showed a valid evaluation until 1/27/2027, so the licence itself was fine. I am not sure why the watermark appeared first.

4. **The pasted firewall command was split in two.**
   - I saw: PowerShell ran only the first line and gave an error on the second.
   - It turned out to be: the rule it created had only a name, with no protocol and no ICMP type, so it was not the "allow only ping" rule I wanted.
   - I did: removed it and created the correct rule with the full command from step 6.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address 10.0.2.4 on the NAT Network
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu address 10.0.2.3 on the same network
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — pings in both directions and to the internet, after the firewall rule
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory with both guests off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory with both guests overcommitted (20 GB + 20 GB on a 31.2 GB host)
