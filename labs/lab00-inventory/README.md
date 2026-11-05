# Lab 0 — Inventory your own machine

Pair: Arsen                     Driver first half: Kazhymurat
Machine: Laptop
Date: 19.10.2026

## What I did

entered commands via the command line to find information about my laptop.


## What did not work the first time

What I saw: Initial status checks evaluated HypervisorPresent = False, which incorrectly implied that virtualization was disabled.

What it turned out to be: HypervisorPresent only indicates whether a Hyper-V hypervisor is actively running, not whether the hardware firmware supports virtualization.

What I did about it: Switched the command query to VirtualizationFirmwareEnabled, which correctly confirmed that virtualization is enabled in the BIOS/UEFI.


## Update

The errors have been corrected in the subsequent screenshots.
