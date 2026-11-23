# Ticket 2 — Four builds

All prices are from shop.kz (White Wind, Almaty), taken on **2026-11-23**, online price, VAT included.
Full list with links: [budget.csv](budget.csv). Compatibility and power were checked part by part (see the table at the end). PCPartPicker did not open (Cloudflare check) — see [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md).

**The most important fact about prices this month:** memory is very expensive in Kazakhstan right now.
32 GB of DDR5 (2×16) costs **282,990 KZT**, 32 GB of DDR4 (2×16) costs **139,990 KZT**, and 64 GB of DDR5 (2×32) costs **739,990 KZT**.
DDR5 is about twice the price of DDR4. That one fact decided the platform for three of the four machines.

---

### Build 1 — accountant

**Load:** accounting software (1C-type) and the bank client, Excel with large tables, browser, email, PDFs of invoices. 8 hours a day, 3–5 programs open at once. Many of these programs run on Windows only.

**Bottleneck:** not the CPU and not memory — it is **the screen and the data**. The accountant is always copying numbers from one window to another (bank statement → accounting program → Excel), so a second monitor saves more time than any faster processor. The other risk is losing the accounting database during a power cut, which is why there is a UPS. 16 GB is enough: this load is around 6–8 GB.

**Trade-off:** took a 4-core Core i3-12100 instead of a Core i5 — the CPU sits at a few percent in this job. The money went to a **second 24" monitor and a UPS** instead. I first picked the cheapest board (MSI PRO B760M-E, 43,590 KZT), then saw it has only HDMI + VGA and the monitors have HDMI + DisplayPort, so two monitors would not connect. I changed it to the Gigabyte B760M DS3H DDR4 (HDMI + 2× DisplayPort, 4 memory slots) for 19,400 KZT more. The alternative I did not take was one 27" monitor and a Core i5 (about the same price) — less useful for this person.

**Total:** 588,310 KZT (budget.csv, rows 2–14)

---

### Build 2 — sales manager

**Load:** CRM in the browser, 30–40 tabs, Excel, WhatsApp Web / Telegram, around four hours of video calls a day, often all at the same time.

**Bottleneck:** **memory**, not CPU. Chrome with 40 tabs plus a video call is around 11–12 GB; on 16 GB with Windows on top the machine starts to swap in the middle of a call with a customer (I saw what swapping does in Lab 6). Second need: a headset and a webcam, otherwise the video calls are bad no matter how fast the PC is.

**Trade-off:** 32 GB of DDR4 instead of DDR5. On an AM5 / DDR5 platform the same 32 GB would cost 282,990 KZT instead of 139,990 KZT. I accepted an older platform (Intel LGA1700, the last generation for this socket) to put the money into the amount of memory. The board has 4 slots, so it can go to 64 GB later by adding a second kit.

**Total:** 631,000 KZT (budget.csv, rows 15–27)

---

### Build 3 — web developer

**Load:** VS Code, Docker with 3–5 containers (web server, database, cache), sometimes one VM, two or three browsers with dev tools open, a local database. Rebuilds the project many times a day.

**Bottleneck:** **memory first, then CPU cores.** Each container and the VM reserve their own memory, exactly like in Lab 2 (host + guest have to fit into the physical RAM). Docker + a VM + browsers easily goes past 32 GB. Builds use all cores, so 10 cores / 16 threads matter more here than in any other role.

**Trade-off:** 64 GB as **4 × 16 GB DDR4** (two 2×16 kits) on a 4-slot board, for 279,980 KZT. 64 GB of DDR5 would be 739,990 KZT — that alone would be a quarter of the whole budget. With 4 sticks DDR4 runs at 3200 MHz, slower than DDR5, but in this job *having* the memory matters much more than its speed. The OS is **Ubuntu 24.04 LTS**: it is free and properly licensed (GPL, Canonical), the company's sites will run on Linux servers anyway, and Docker runs natively. If the developer needs Windows-only software later, a Windows licence is 102,990 KZT from the reserve.

**Total:** 662,810 KZT (budget.csv, rows 28–39)

---

### Build 4 — designer

**Load:** Photoshop / Illustrator / Figma, large layered files (1–3 GB), sometimes short video editing; colour must look the same on screen as in print and on the client's phone.

**Bottleneck:** **the monitor and the GPU**, then memory. A cheap monitor shows colours wrong, and no processor fixes that. Adobe programs use the GPU for filters, zoom and video export; the Ryzen's built-in graphics is too weak for that. Big layered files need 32 GB.

**Trade-off:** the most expensive machine, on purpose. The money went to a **27" QHD monitor with 99% sRGB** (135,490 KZT) and an **RTX 5050 8 GB** (220,990 KZT). I did not take the RTX 5060 (~320,000 KZT) — the extra 100,000 KZT gives more gaming speed than design speed. This is the only machine on AM5 / DDR5, because it is the machine most likely to need a faster CPU in a few years, and AM5 will get new processors (LGA1700 will not). It has only 2 memory slots, so going to 64 GB later means replacing the kit, not adding to it.

**Total:** 1,046,900 KZT (budget.csv, rows 40–51)

---

## Budget

| Role | Total, KZT |
|---|---:|
| Accountant | 588,310 |
| Sales | 631,000 |
| Web developer | 662,810 |
| Designer | 1,046,900 |
| **All four** | **2,929,020** |
| Left from 3,000,000 | 70,980 |

The 70,980 KZT left is kept as a reserve for cables, a network switch or delivery — and because memory prices are moving week to week (see section 5 of the README).

## Compatibility check

| Check | Accountant | Sales | Web dev | Designer |
|---|---|---|---|---|
| CPU socket ↔ board | LGA1700 ↔ LGA1700 (B760) | LGA1700 ↔ LGA1700 (B760) | LGA1700 ↔ LGA1700 (B760) | AM5 ↔ AM5 (B650) |
| Memory ↔ board | DDR4, 2 sticks / 4 slots | DDR4, 2 sticks / 4 slots | DDR4, 4 sticks / 4 slots | DDR5, 2 sticks / 2 slots |
| SSD ↔ board | M.2 NVMe PCIe 4.0 | M.2 NVMe PCIe 4.0 | M.2 NVMe PCIe 4.0 | M.2 NVMe PCIe 4.0 |
| Video output | CPU graphics (UHD 730); monitor 1 on HDMI, monitor 2 on DisplayPort | CPU graphics (UHD 730) | CPU graphics (UHD 730) | RTX 5050 (monitor into the card, not the board) |
| Cooler | SE-904-XT, 123 mm, fits case (≤151 mm), supports LGA1700 and AM5 | same | same | same |
| GPU length | — | — | — | 169.9 mm, case allows 250 mm |
| Power (estimate) | ~150 W on 550 W | ~180 W on 550 W | ~220 W on 550 W | ~330 W on 650 W |

The CPUs are all **OEM** (no cooler in the box), so every build has its own cooler. All four CPUs have built-in graphics, so the three machines without a graphics card can still show a picture.
