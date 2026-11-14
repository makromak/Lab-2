#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8 with BOM, keep CRLF
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv
printf '\357\273\277' > "$out"                 # 1. write the UTF-8 BOM (EF BB BF)
iconv -f RK1048 -t UTF-8 "$in" >> "$out"       # 2. convert the text and append it
