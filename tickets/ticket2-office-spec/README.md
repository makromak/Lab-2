# Ticket 2 — Kitting out the new office

## 1. What was asked

> From: Daniyar K. (Director)
> Subject: computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Four identical machines is the wrong answer.** The four people put completely different loads on a computer, so each one runs out of a different resource first:

| Person | What runs out first |
|---|---|
| Accountant | screen space and data safety (not CPU) |
| Sales manager | memory (browser tabs + video calls) |
| Web developer | memory and CPU cores (containers, VM, builds) |
| Designer | colour-accurate monitor and GPU |

If all four are the same, there are only two options. Either every machine is good enough for the designer and the developer — then the company pays for a graphics card and 64 GB of memory that the accountant will never use, and 3,000,000 KZT is not enough. Or every machine is "average" — then the developer and the designer are slow every day and the accountant has a CPU that sits idle. One thing *is* worth keeping the same: the same case, SSD, cooler and power supply where possible, so spare parts and repairs are simpler.

**What the request left out.** "Monitors included" — but four working places also need:
- an **operating system licence** for each machine (Windows 11 Pro is 102,990 KZT, ×4 is over 400,000 KZT — this is the biggest forgotten cost);
- **keyboard and mouse** for each;
- a **headset and webcam** for the sales manager, who is on calls four hours a day;
- a **UPS** at least for the accountant, so a power cut does not break the accounting database;
- cables, a network switch, delivery and setup time;
- **backups** — nobody mentioned where the accountant's and designer's files will be copied.

**What "last a few years" means.** I took it as **4–5 years**. For the platform that means: enough memory now (16–64 GB, not 8), a 1 TB SSD, and a board with free slots so memory can be added later.

**What I would ask Daniyar, and what I assumed instead:**

| Question | What I assumed |
|---|---|
| Is 3,000,000 KZT only for computers and monitors, or also Windows, keyboards, a UPS, setup? | Everything that sits on the desk is inside the 3,000,000 KZT, including OS licences and peripherals. Network equipment and setup are paid from the reserve. |
| Do you already have Windows licences (for example a Microsoft 365 / volume licence from the first office)? | No — I priced a retail Windows 11 Pro for three machines. |
| Which accounting program does the accountant use (1C, something online)? Does the bank client need Windows? | 1C-type software and a bank client that need Windows. |
| Does the designer make print layouts, web graphics or video? | Mostly graphics and layouts in Adobe / Figma, some short video. |
| Does the developer need Windows, or is Linux fine? | Linux is fine: the sites will be hosted on Linux servers. |
| Is it OK to have two different platforms (Intel and AMD) in one office? | Yes, if each choice is explained. |
| Should the PCs be built by us or bought ready-made? | Built from parts, but I priced ready-made machines too (question 2 below). |

## 3. What I did

1. **From role to load to bottleneck.** For each person I first wrote down what they run all day and what runs out first, *before* choosing any part. This is in [builds.md](builds.md): every build has Load · Bottleneck · Trade-off · Total.
2. **Prices.** I took every price from one Kazakhstan vendor, **shop.kz (White Wind, Almaty)**, on **2026-11-23**, the online price with VAT. Every row in [budget.csv](budget.csv) has the product link and the date.
3. **The surprise: memory prices.** While pricing I found that DDR5 is about twice the price of DDR4 right now (32 GB DDR5 282,990 KZT vs 32 GB DDR4 139,990 KZT; 64 GB DDR5 739,990 KZT). This changed the plan: three machines are on **Intel LGA1700 + DDR4**, so the money goes into the *amount* of memory, and only the designer — who will need a CPU upgrade first — is on **AM5 + DDR5**.
4. **Money goes to the bottleneck.** The accountant got two monitors and a UPS instead of a faster CPU; the sales manager got 32 GB and a headset; the developer got 64 GB and 10 cores; the designer got the colour-accurate monitor and the graphics card.
5. **Compatibility.** Checked socket ↔ board, memory type ↔ board, M.2 ↔ SSD, cooler height ↔ case, GPU length ↔ case, power ↔ PSU, video outputs ↔ monitors (table at the end of builds.md). PCPartPicker would not open for me (blocked by a Cloudflare check), so these checks were done by hand from the shop's spec pages.

**Result:** four machines, all with ≥ 16 GB memory, a 1 TB NVMe SSD, a licensed OS and a monitor.

| Role | Total, KZT |
|---|---:|
| Accountant | 588,310 |
| Sales | 631,000 |
| Web developer | 662,810 |
| Designer | 1,046,900 |
| **Grand total** | **2,929,020** (70,980 left of 3,000,000) |

### The director's three questions

**1. Which machine will you upgrade first, 18 months from now, and why?**
The **web developer's**, and the part is the **SSD** — a second 1 TB NVMe in the free M.2 slot. Docker images, databases and VM disks grow every month, and 1 TB will be full in about a year and a half. This is cheap (about 86,000 KZT today) and takes ten minutes. The designer's machine is the next one: on AM5 the CPU can be swapped for a newer Ryzen without changing the board, which is exactly why I put the designer on AM5.

**2. Pre-built vs built: what does the company gain and lose?**
I priced the closest ready-made machines from the same vendor (WW-KZ, shop.kz, 2026-11-23) in [prebuilt.csv](prebuilt.csv). None of them includes Windows, and the price is for the system unit only.

| Role | Ready-made unit | Price, KZT | My unit, KZT | What is different |
|---|---|---:|---:|---|
| Accountant | i3-12100, 16 GB, 512 GB | 266,990 | 319,350 | half the SSD |
| Sales | i5-14400, 16 GB DDR5, 512 GB | 374,490 | 420,050 | 16 GB instead of 32 GB |
| Web dev | i5-14400, 16 GB DDR5, 512 GB | 374,490 | 563,530 | 16 GB instead of 64 GB; 64 GB DDR5 would cost ~740,000 more |
| Designer | Ryzen 5 7500F, RTX 5060, 16 GB DDR5, 1 TB | 707,790 | 794,130 | stronger GPU, but 6 cores and 16 GB as **one** stick (1×16 GB, single channel) |

*Gains with ready-made:* one 12-month warranty for the whole box from one shop, it is assembled and tested, no time spent building, and the office gets the computers faster. For the accountant it is even a bit cheaper.
*Losses:* the ready-made machines save money exactly where these people need it — 16 GB of memory and 512 GB SSDs. To bring them to my spec you would have to replace the memory and SSD on day one, which costs more than building. You also don't choose the PSU or board (the i5-14400 model has a 400 W PSU), and the upgrade path is unclear. My recommendation: **ready-made for the accountant is acceptable, build the other three.**

**3. Who will complain first, within a month, and about what?**
The **designer**, about **video**. The RTX 5050 is fine for Photoshop and Figma, but if Daniyar's company starts making video for social media, exporting a few minutes of 4K will be slow, and 8 GB of video memory will be tight with big files. That is the trade-off I chose (not the RTX 5060) to stay in budget, so it is where it will hurt first. Second most likely: the **sales manager**, about the **webcam** — the C270 is only 720p and looks poor on client calls.

## 4. Evidence

| File | What it proves |
|---|---|
| [budget.csv](budget.csv) | every part, price in KZT, vendor link, date; per-role totals and the grand total (≤ 3,000,000) |
| [prebuilt.csv](prebuilt.csv) | prices of ready-made machines for question 2, with links and date |
| [builds.md](builds.md) | load, bottleneck and trade-off for every build, plus the compatibility table |
| [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) | why there are no PCPartPicker lists (site blocked by a Cloudflare check) and the manual compatibility checks done instead |
| [evidence/vendor-quotes/](evidence/vendor-quotes/) | list of the price screenshots taken on shop.kz (part, file name, price); the image files are not uploaded yet — see the note there |

## 5. What I would do differently

- **Start pricing earlier and on more than one shop.** I took all prices from one vendor on one day. Memory prices in Kazakhstan are changing week to week right now, so I should have compared shop.kz with Kaspi, Technodom and DNS, and taken the price a few days before buying, not only once.
- **Check the video outputs before choosing the board.** I picked the cheapest board for the accountant and only later saw it has HDMI + VGA, so the second monitor (HDMI + DisplayPort) could not connect. Next time I would write down "number of monitors → video outputs needed" as a requirement at the start, the same way as memory and SSD.
- **Ask Daniyar first.** The biggest unknowns (existing Windows licences, which accounting program) change the budget by hundreds of thousands of tenge; one short email before pricing would have saved guessing.
