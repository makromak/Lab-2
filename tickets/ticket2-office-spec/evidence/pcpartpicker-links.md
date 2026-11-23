# PCPartPicker

**No PCPartPicker lists — the site did not open.** On 2026-11-23 pcpartpicker.com showed a Cloudflare "verify you are human" page that did not let me through, even after clicking the check box several times. Without the site I could not save the lists.

What I did instead (the same checks PCPartPicker does):

| PCPartPicker check | How I checked it | Where |
|---|---|---|
| CPU socket ↔ motherboard socket | socket on the CPU page and on the board page at shop.kz | builds.md, compatibility table |
| Memory type and number of sticks ↔ board slots | "Количество слотов памяти" on the board page (4× DDR4, 2× DDR5) | builds.md |
| M.2 SSD ↔ board | M.2 slots on the board page (B760M DS3H DDR4: 2× M.2; B650M-B: 1× M.2) | builds.md |
| Cooler height ↔ case | cooler 123 mm, Matrexx 30 allows 151 mm | builds.md |
| Cooler socket support | SE-904-XT supports LGA1700 and AM5 | screenshot all-cpu-cooler.png |
| GPU length ↔ case | RTX 5050 StormX 169.9 mm, case allows 250 mm | builds.md |
| Power | estimate of CPU TDP + GPU + ~50 W for the rest, compared with the PSU | builds.md |
| Video outputs ↔ monitors | board video outputs vs monitor inputs (this check found a mistake — see README section 5) | builds.md |

If the site works later, I will add the four lists here.
