#!/usr/bin/env bash
# Lab 4 — Partition, mirror, fail, recover (Linux part).
# Runs the commands from the Canvas step-by-step guide, in the same order,
# and saves each state of the mirror to evidence/ at the moment it happens.
# Run inside the Ubuntu VM:  bash <(curl -sL raw.githubusercontent.com/makromak/Lab-2/main/lab4.sh)
set -u
mkdir -p ~/lab04/evidence && cd ~/lab04
exec > >(tee -a ~/lab04/evidence/session-log.txt) 2>&1
echo "== Lab 4 started: $(date)"
sudo -v || exit 1

echo; echo "== Step 3 - look before you touch"
{ echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS'; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS; } > evidence/lsblk-before.txt
cat evidence/lsblk-before.txt

# the three new disks: type "disk", exactly 1 GiB, nothing on them
mapfile -t NEW < <(lsblk -dnbo NAME,SIZE,TYPE | awk '$2==1073741824 && $3=="disk" {print $1}')
if [ "${#NEW[@]}" -ne 3 ]; then echo "STOP: expected 3 empty 1 GiB disks, found: ${NEW[*]:-none}"; exit 1; fi
for d in "${NEW[@]}"; do
  if [ "$(lsblk -no NAME /dev/$d | wc -l)" -ne 1 ]; then echo "STOP: /dev/$d already has partitions"; exit 1; fi
done
D1=${NEW[0]}; D2=${NEW[1]}; D3=${NEW[2]}
echo "The three new disks: $D1 $D2 $D3"

echo; echo "== Step 4 - one partition on each disk, marked for RAID"
for d in $D1 $D2 $D3; do
  echo "$ sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on"
  sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on
done
sleep 2; lsblk
P1=/dev/${D1}1; P2=/dev/${D2}1; P3=/dev/${D3}1

echo; echo "== Step 5 - build the mirror from two of them"
command -v mdadm >/dev/null || sudo apt install -y mdadm
echo "$ sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 --run $P1 $P2"
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 --run $P1 $P2
sleep 1
while grep -qE 'resync|recovery' /proc/mdstat; do cat /proc/mdstat; sleep 1; done
cat /proc/mdstat
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-healthy.txt

echo; echo "== Step 6 - file system, mount, proof file, checksum"
sudo mkfs.ext4 -F -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER: /mnt/mirror
echo "Lab 4 proof file — Arsen Yermakanov — $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-before.txt; cd ~/lab04
cat evidence/checksum-before.txt

echo; echo "== Step 7 - fail one disk on purpose"
echo "$ sudo mdadm /dev/md0 --fail $P2"; sudo mdadm /dev/md0 --fail $P2
echo "$ sudo mdadm /dev/md0 --remove $P2"; sudo mdadm /dev/md0 --remove $P2
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-degraded.txt
cat /proc/mdstat
cat /mnt/mirror/proof.txt
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-after-failure.txt; cd ~/lab04
diff <(tail -n +2 evidence/checksum-before.txt) <(tail -n +2 evidence/checksum-after-failure.txt) && echo "checksums match"

echo; echo "== Step 8 - add the third disk and rebuild"
echo "$ sudo mdadm /dev/md0 --add $P3"; sudo mdadm /dev/md0 --add $P3
sleep 1
while grep -qE 'resync|recovery' /proc/mdstat; do cat /proc/mdstat; sleep 1; done
cat /proc/mdstat
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-rebuilt.txt
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
{ echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS'; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS; } > evidence/lsblk-after.txt
cat evidence/lsblk-after.txt

echo; echo "== Done: $(date). Evidence files:"; ls -l ~/lab04/evidence
echo; echo "== Step 9 - the evidence is now served at http://$(hostname -I | awk '{print $1}'):8000/  (Ctrl+C to stop)"
cd ~/lab04/evidence && exec python3 -m http.server 8000
