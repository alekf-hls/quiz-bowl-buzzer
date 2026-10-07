# Quiz Bowl Buzzer: Starter Kit and Add-ons

Date: 2026-10-07. Prices are rough single-unit online prices (AliExpress/Amazon); they'll vary.
Goal: a cheap set you can play with now, and add to without rebuilding anything.

## Rules that keep add-ons cheap
- **Build every station for the max from day one.** Each team station gets all 8 player jacks and 8 player lights fitted even before any player buttons exist (under $0.70 per seat). Adding players later is then just plugging in buttons.
- **Use 4-wire TRRS cables** on every player button, even ones without lights, so lit buttons can plug in later.
- **Firmware detects what's fitted**: no player buttons, no OLED, no ULN2803, any number of stations (1-4) all just work.
- **Battery + wall power is built in from the start.** To save ~$20 you can skip the batteries at first and run every unit from a USB-C wall charger; the board and USB-C socket are the same either way.
- **Any phone or laptop is the scoreboard** until you want a dedicated HDMI box.

## Stage 1: Starter kit, base + 2 team stations, team buttons only (~$80)
Play a full team game right away: each team buzzes with the **team button** built into its station. Includes lockout, scoring, host page, scoreboard in a browser, which-team lights on the base, and USB-C rechargeable batteries that also run from wall power. No individual player buttons yet; the jacks are ready for them.

| Item | Qty | Each | Total |
|---|---|---|---|
| ESP32-S3 DevKitC (base) | 1 | $10 | $10 |
| Base parts: 4 tactile buttons, active buzzer, 2N2222, 2 LEDs, resistors | 1 set | $5 | $5 |
| PL9823 5 mm RGB LED (4 team lights on base) | 4 | $0.25 | $1 |
| ESP32 DevKitC (team stations) | 2 | $5 | $10 |
| 30 mm team button on each station lid | 2 | $1 | $2 |
| TRRS panel jacks (all 8 per station, ready for player buttons) | 16 | $0.40 | $6.40 |
| PL9823 5 mm RGB LED (8 player lights per station) | 16 | $0.25 | $4 |
| Perfboard, headers, wire, 1 kΩ/330 Ω/10 kΩ resistors, capacitors | 1 lot | $10 | $10 |
| 3D-printed enclosures: base + 2 stations (filament) | ~300 g | | $6 |
| 18650 cell + holder | 3 | $3.50 | $10.50 |
| USB-C UPS board (charge + boost, pass-through) | 3 | $3 | $9 |
| Slide switch, 1000 µF capacitor | 3 | $0.50 | $1.50 |
| **Stage 1 total** | | | **~$80** (~$60 without batteries, running from wall chargers) |

Even cheaper: leave the jacks and player lights out of the stations for now (−$10, so ~$70). The holes are already in the printed boxes, but you'd be soldering them in later instead of just plugging buttons in.

## Add-ons (any order)

| Add-on | What it adds | Cost |
|---|---|---|
| **Player buttons** | 30 mm arcade button + 2 m TRRS cable + printed housing, plugs into any station jack | ~$3.50 each: ~$14 for 4 on a team, ~$28 for a full team of 8 |
| **Third team** | 1 station (ESP32, team button, 8 jacks, 8 lights, battery + USB-C board) + enclosure | ~$24 |
| **Fourth team** | same | ~$24 |
| **Base screen** | 1.3" OLED showing team name + seat | ~$5 |
| **HDMI scoreboard box** | Raspberry Pi Zero 2 W + case, mini-HDMI cable, power, microSD | ~$35 |
| **Lit buttons (optional)** | ULN2803 per station + 60 mm LED arcade buttons instead of 30 mm | ~$1 per station + ~$3 more per button |

## Totals
- Starter: **~$80**
- Starter + 4 player buttons on each team (2 teams x 4): **~$108**
- Max size (4 teams x 8 player buttons), base screen, batteries, HDMI box, without lit buttons: **~$80 + $24x2 + 32 x $3.50 + $5 + $35 ≈ $280**
- Lit buttons on top: **~+$100**.

**Recommendation:** skip lit buttons. The player light above each jack already shows who buzzed. If you do want them, buy 60 mm LED buttons from the start rather than replacing 30 mm ones.

## Suggested order
1. Starter kit; play team games with the team buttons.
2. Player buttons for both teams when you want to know who buzzed.
3. Base screen ($5) once the moderator wants the player name on the base.
4. Third and fourth stations as you grow.
5. HDMI box when you want the TV scoreboard without a laptop.
