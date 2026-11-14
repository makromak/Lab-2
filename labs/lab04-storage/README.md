# Lab 4 — Partition, mirror, fail, recover

Student: Arsen Yermakanov · Group: CYB26-5 · Date: 14 November 2026
Done individually at home · Host: MacBook (Apple M1) · Hypervisor: UTM (QEMU, ARM64) · Guest: Ubuntu Server 26.04.1 LTS

Because the disks are attached through VirtIO, they are called `vdb`, `vdc`, `vdd` (not `sdb`, `sdc`, `sdd` as in the guide). `vda` is the system disk.

## Windows

**Not done yet.** I do not have a Windows guest on this Mac at the moment (an Apple Silicon host needs Windows 11 ARM), so the NTFS partition part is missing. The commands I would run on the new 1 GB disk (disk 1, never disk 0):

```powershell
Get-Disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter |
  Format-Volume -FileSystem NTFS -NewFileSystemLabel LAB04
Get-Disk | Select Number, FriendlyName, PartitionStyle, Size
Get-Volume | Where FileSystemLabel -eq 'LAB04'
```

MBR or GPT: **GPT**. Windows 11 boots with UEFI, and UEFI uses GPT; GPT also keeps a backup copy of the partition table and protects it with a checksum, while MBR is limited to 2 TiB and four primary partitions.

## Linux — layout before and after

### Before

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME                       SIZE TYPE FSTYPE      MOUNTPOINTS
sr0                       1024M rom              
vda                         32G disk             
├─vda1                       1G part vfat        /boot/efi
├─vda2                       2G part ext4        /boot
└─vda3                    28.9G part LVM2_member 
  └─ubuntu--vg-ubuntu--lv 14.5G lvm  ext4        /
vdb                          1G disk             
vdc                          1G disk             
vdd                          1G disk             
```

### After

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME                       SIZE TYPE  FSTYPE            MOUNTPOINTS
sr0                       1024M rom                     
vda                         32G disk                    
├─vda1                       1G part  vfat              /boot/efi
├─vda2                       2G part  ext4              /boot
└─vda3                    28.9G part  LVM2_member       
  └─ubuntu--vg-ubuntu--lv 14.5G lvm   ext4              /
vdb                          1G disk                    
└─vdb1                    1022M part  linux_raid_member 
  └─md0                   1021M raid1 ext4              /mnt/mirror
vdc                          1G disk                    
└─vdc1                    1022M part  linux_raid_member 
vdd                          1G disk                    
└─vdd1                    1022M part  linux_raid_member 
  └─md0                   1021M raid1 ext4              /mnt/mirror
```

`md0` (raid1, ext4) now sits on `vdb1` and `vdd1` and is mounted on `/mnt/mirror`. `vdc1` is the disk I failed and removed; it still carries the RAID signature but is no longer part of the array.

## What I did

Partition the three disks (one GPT partition each, flagged for RAID):

```bash
for d in vdb vdc vdd; do
  sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on
done
```

Build the mirror from two of them and save the healthy state:

```bash
sudo apt install -y mdadm
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdb1 /dev/vdc1
cat /proc/mdstat
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-healthy.txt
```

This version of mdadm also asked whether to enable a write-intent bitmap; I answered `y`, which is why `/proc/mdstat` shows a `bitmap:` line.

File system, mount, proof files, checksum before the failure:

```bash
sudo mkfs.ext4 -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER: /mnt/mirror
echo "Lab 4 proof file — Arsen Yermakanov — $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-before.txt; cd ~/lab04
```

Fail one disk on purpose (with `--fail`, not by detaching the disk in UTM), save the degraded state, check the data:

```bash
sudo mdadm /dev/md0 --fail /dev/vdc1
sudo mdadm /dev/md0 --remove /dev/vdc1
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-degraded.txt
cat /mnt/mirror/proof.txt
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-after-failure.txt; cd ~/lab04
diff <(tail -n +2 evidence/checksum-before.txt) <(tail -n +2 evidence/checksum-after-failure.txt) && echo "checksums match"
```

```
checksums match
```

Add the third disk, let the array rebuild, save the rebuilt state, keep the array after a reboot:

```bash
sudo mdadm /dev/md0 --add /dev/vdd1
cat /proc/mdstat
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-rebuilt.txt
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

The 1 GB rebuild finished within seconds, so I did not catch a `recovery = …%` line.

## Three states

| State | What /proc/mdstat showed | mdadm --detail | File |
| --- | --- | --- | --- |
| Healthy | `[2/2] [UU]`, vdb1 + vdc1 | State : clean, 2 active devices | evidence/array-healthy.txt |
| Degraded | `[2/1] [U_]`, vdb1 only | State : clean, degraded, slot 1 removed | evidence/array-degraded.txt |
| Rebuilt | `[2/2] [UU]`, vdb1 + vdd1 | State : clean, vdd1 replaced vdc1 | evidence/array-rebuilt.txt |

Checksums before and after the failure: **match** (both files identical, see `checksum-before.txt` and `checksum-after-failure.txt`).

## RAID is not a backup

*Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?*

No. RAID 1 writes every change to both disks at the same moment, so the deletion was mirrored instantly and the file is gone from both copies. RAID protects against a disk failing, not against a human mistake, malware or a fire — for that you need a backup: a separate copy from an earlier point in time, kept somewhere else.

## What did not work the first time

1. **The array was not created on the first try.** mdadm asked two y/N questions (write-intent bitmap, then "Continue creating array?"). I typed `yes` instead of `y`; mdadm printed `bad option` twice and `create aborted`. I did not notice at once and ran the "healthy" capture anyway — it showed `unused devices: <none>` and `mdadm: cannot open /dev/md0: No such file or directory`. I ran `--create` again, answered with a single `y` to each question, got `array /dev/md0 started`, and saved `array-healthy.txt` again (the `>` overwrote the wrong file).
2. **SSH was not set up.** I typed two commands on one line (`sudo apt install -y openssh-server ip -br addr`); apt answered `Command line option 'b' [from -br] is not understood` and installed nothing. Running the commands one per line fixed it, and I then worked over SSH from the Mac terminal.

## Evidence

- `evidence/lsblk-before.txt` — three empty 1 GB disks (vdb, vdc, vdd) before any change
- `evidence/array-healthy.txt` — mirror of vdb1 + vdc1, `[UU]`, clean
- `evidence/checksum-before.txt` — SHA-256 of proof.txt and random.bin before the failure
- `evidence/array-degraded.txt` — after failing and removing vdc1: `[U_]`, clean, degraded
- `evidence/checksum-after-failure.txt` — the same two sums on the degraded array (identical)
- `evidence/array-rebuilt.txt` — after adding vdd1: `[UU]` again, vdb1 + vdd1
# Lab 4 — Partition, mirror, fail, recover

Pair:                     Driver first half:
Machine:
Date:

## What I did

Steps, with commands in code blocks. Not prose about the steps.

```
<command>
<output, trimmed>
```

## Result

## What did not work the first time

At least one thing. What I saw, what it turned out to be, what I did about it.

## Evidence

- [evidence/](evidence/) — one line per file on what it proves
