# Ticket 1 — New developer starts Monday, needs a test machine

## 1. What was asked

> From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks

## 2. What was actually needed

**What the request means, not just what it says.**

- "A test computer" for a developer is not a second physical PC. It is a virtual machine on the computer he already has. A VM costs nothing and is ready in an hour. A spare PC has to be bought and delivered.
- "Nothing special" is not true for a developer. He will most likely need both Linux, where most servers and tools run, and Windows, which most of our users run. So I built two guests: Ubuntu Server 26.04 LTS and Windows 11 Enterprise (evaluation).
- "Without breaking anything" can mean two things:
  1. *Not breaking the host.* A VM is isolated, so a mistake inside the guest does not touch the real laptop.
  2. *Getting back after he breaks the VM.* This is what the request really needs, and it is the part Aigerim would not think to ask for. The answer is a **clean snapshot** taken right after installation. Rolling back takes one click.
- "Write down how to do it so I can do the next one myself" means the real deliverable is a document, not a machine. The reader is Aigerim, who is not an IT person. Every step in BUILD.md must work for her without help.

**What the request leaves out, and what I assumed instead.**

| Question I would ask Aigerim | What I assumed |
|---|---|
| What laptop will he use? How much memory and disk does it have? | At least 16 GB RAM and 150 GB free disk, with a CPU that supports virtualization. I built and tested on a 32 GB laptop. With less than 16 GB, both guests cannot run at the same time. |
| Does he need the internet inside the VMs? | Yes. A developer installs packages. |
| Do the two VMs need to talk to each other? | Yes. Testing a client on Windows against a server on Linux is a normal developer task. |
| Is he allowed to install software on his laptop? | Yes. VirtualBox needs administrator rights once. |
| Is there a budget for licences? | No. Everything has to be free and legal for an office. VirtualBox is free (GPLv3). Ubuntu is free. Windows 11 Enterprise **evaluation** is free for 90 days. |
| What happens after 90 days of Windows? | Not decided. Either IT buys a licence, or the Windows VM is rebuilt from this document. I flag this to Aigerim instead of hiding it. |

**Where the request is wrong.** "Nothing special" suggests that anyone can click through an installer. In fact four settings are not defaults and will fail if skipped: TPM 2.0 and EFI for Windows 11, the network mode, and a firewall rule for ping. BUILD.md explains each one.

## 3. What I did

I built both guests in Lab 1 and Lab 2. For this ticket I wrote that work down so that someone else can repeat it. The full steps are in [BUILD.md](BUILD.md). The key decisions are below.

**Two hosts, because I work on a Mac.**

| | Linux guest | Windows guest |
|---|---|---|
| Host | My MacBook Air (M1, 2020): 8 cores, 8 GB RAM, 245 GB SSD with 187 GB free | Kazhymurat's laptop (pair partner): AMD Ryzen 9 8940HX, 32 GB RAM (31.2 GB usable), Windows |
| Hypervisor | UTM (QEMU backend, so snapshots work) | VirtualBox |
| Guest | Ubuntu Server 26.04.1 LTS, ARM64 | Windows 11 Enterprise evaluation, x86-64 |
| CPU / RAM | 2 cores / 2048 MB | 4 vCPU / 4096 MB |
| Disk | VirtIO, qcow2, grows on demand (14.14 GB seen by the guest, 7.16 GB on the Mac) | 64 GB VDI, dynamically allocated |
| Network | UTM **Shared Network** (192.168.64.0/24) | VirtualBox **NAT Network** (10.0.2.0/24) |

An M1 Mac cannot run the x86 Windows 11 ISO at a usable speed, so the Windows guest and the guest-to-guest test were done on the Windows laptop in Lab 2. On that laptop both guests ran in VirtualBox on one NAT Network, which is what BUILD.md describes for Aigerim's (Windows) office laptop.

**Resources, calculated from the host.**

- *My Mac, 8 GB RAM.* Memory is the tightest resource. Ubuntu Server has no desktop and used 15% of its 2 GB at idle (login banner on 8 Nov: "Memory usage: 15%"). 2 GB is 25% of the Mac's RAM and leaves 6 GB for macOS. 2 of 8 cores keep the Mac responsive. The disk is about 14 GB, which is 8% of the 187 GB free, and the qcow2 file only takes 7.16 GB because it grows as the guest writes.
- *Partner's laptop, 31.2 GB usable.* Windows on the host used about 8 GB at idle (Lab 2, Task Manager). Two guests at 4 GB each make 8 + 8 = 16 GB in use, which leaves about 15 GB of headroom. In Lab 2 I overcommitted to 20 GB + 20 GB. Available memory fell to 4.0 GB and committed memory almost reached its limit, so 4 GB each is safe and 20 GB each is not.
- *Aigerim's typical 16 GB office laptop.* 16 − ~6 GB host idle = 10 GB. Two guests at 4 GB = 8 GB, which leaves ~2 GB headroom: tight but workable. On an 8 GB laptop, run one guest at a time, or give Ubuntu 2 GB as I did on my Mac.

**Settings that differ from the default.**

| Setting | Default | Mine | Why |
|---|---|---|---|
| Windows VM memory | wizard suggestion | 4096 MB | Calculated above. Two guests fit with headroom. |
| Windows VM vCPU | 1 | 4 | Windows 11 is slow on 1–2 vCPU. The host has 32 threads. |
| Windows firmware | depends on wizard | EFI + Secure Boot | Windows 11 refuses to install without them. |
| Windows TPM | depends on wizard | TPM 2.0 | Windows 11 requirement. |
| Ubuntu VM memory (UTM, my Mac) | wizard suggestion | 2048 MB | The Mac has only 8 GB. The server used 15% of 2 GB at idle. |
| Ubuntu VM CPU (UTM) | default | 2 cores | Leaves 6 of 8 cores to macOS. |
| UTM backend | Apple Virtualization | QEMU | Apple Virtualization has no snapshots in UTM. Snapshots are the whole point of "without breaking anything". |
| Network (both VMs) | NAT | **NAT Network** `NatNetwork` | Plain NAT gives each VM its own private router, so the guests cannot see each other. Host-only has no internet. Bridged gives the guest its own MAC, and the campus network filters by MAC. |
| Windows Firewall | Blocks inbound ICMP echo | One rule allowing ICMPv4 echo only | So Linux can ping Windows. The firewall stays on for everything else. |
| Port forwarding | none | host 2222 → 10.0.2.3:22 | On a NAT Network the host cannot reach a guest directly. This lets the developer SSH into Ubuntu from the laptop. |

**Network.** On the partner's laptop both guests are on the NAT Network `10.0.2.0/24` with gateway `10.0.2.1`. Ubuntu got `10.0.2.3` and Windows got `10.0.2.4`. On my Mac, Ubuntu is on UTM's Shared Network and got `192.168.64.2` (evidence/04).

```
Ubuntu  $ ip -br a          → enp0s3 UP 10.0.2.3/24
Windows PS> ipconfig        → IPv4 10.0.2.4, gateway 10.0.2.1
```

**What went wrong and how I fixed it.** Windows → Ubuntu ping worked at once, but Ubuntu → Windows lost 100% of packets:

```
$ ping -c 4 10.0.2.4
4 packets transmitted, 0 received, 100% packet loss, time 4115ms
```

Windows Defender Firewall blocks incoming ICMP echo requests by default. I did not turn the firewall off. I added one rule that allows only ping (PowerShell as Administrator):

```
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

After the rule, there was 0% loss both ways, and both guests reached ubuntu.com.

**Licence check (Windows).** No product key was entered.

```
slmgr.vbs /xpr
Windows(R), EnterpriseEval edition: Timebased activation will expire 1/27/2027
```

## 4. Evidence

| File | What it proves |
|---|---|
| [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | The configuration chosen in the UTM new-VM wizard: ARM64, QEMU virt machine, 2048 MiB, 2 cores. |
| [evidence/02-disk-settings.png](evidence/02-disk-settings.png) | The disk: qcow2 image on VirtIO, 7.16 GB on the Mac — grows on demand (thin). |
| [evidence/03-network-adapter.png](evidence/03-network-adapter.png) | Network mode: Shared Network, virtio-net-pci. |
| [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) | `uname -a`, `lsb_release -a` and `ip -br a` inside the Linux guest: Ubuntu 26.04.1 LTS, aarch64, address 192.168.64.2. |
| [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Ubuntu ↔ Windows and each guest → internet, unedited (Lab 2, VirtualBox NAT Network). 0% loss in all four. |
| [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) | UTM snapshot list with `clean-install` (23 Oct), taken right after installation. |

## 5. What I would do differently

- I would collect the screenshots while building, not afterwards. The UTM screenshots here were taken from the finished VM's settings, not from the wizard itself.
- I would name snapshots by what they contain. My second UTM snapshot is called `snapshot-list.png`, which says nothing about the state it saved. A name like `after-lab1` would tell Aigerim what she is restoring.
- I would note the 90-day Windows evaluation expiry date in a calendar for Aigerim on day one.
- I would build on a host that matches the developer's real laptop. I tested on a 32 GB machine, but a typical office laptop has 16 GB, so the numbers in BUILD.md are an estimate for that case.

---

*Use of AI: Claude (Anthropic) was used to draft the structure of this README and BUILD.md from my Lab 1/Lab 2 notes.*
