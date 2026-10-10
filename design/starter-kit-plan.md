# Quiz Bowl Buzzer: Starter Kit and Add-ons

Date: 2026-10-10 (Cat6 cables, unlit player buttons). Prices are rough single-unit online prices (AliExpress/Amazon); they'll vary.
Goal: a cheap set you can play with now, and add to without rebuilding anything.

## Rules that keep add-ons cheap
- **Build every station for the max from day one.** Each team station gets all 8 player jacks and 8 player lights fitted even before any player buttons exist (under $0.70 per seat). Adding players later is then just plugging in buttons.
- **Player buttons use ordinary Cat6 patch cables** (one plug cut off and soldered to the button). Cheap, sturdy, any length, and easy to replace.
- **Firmware detects what's fitted**: no player buttons, no OLED, any number of stations (1-4) all just work.
- **Battery + wall power is built in from the start.** To save ~$20 you can skip the batteries at first and run every unit from a USB-C wall charger; the board and USB-C socket are the same either way.
- **Any phone or laptop is the scoreboard** until you want a dedicated HDMI box.

## Stage 1: Starter kit, base + 2 team stations, team buttons only (~$85)
Play a full team game right away: each team buzzes with the **team button** built into its station. Includes lockout, scoring, host page, scoreboard in a browser, which-team lights on the base, and USB-C rechargeable batteries that also run from wall power. No individual player buttons yet; the jacks are ready for them.

| Item | Qty | Each | Total |
|---|---|---|---|
| ESP32-S3 DevKitC (base) | 1 | $10 | $10 |
| Base parts: 4 tactile buttons, active buzzer, 2N2222, 2 LEDs, resistors | 1 set | $5 | $5 |
| PL9823 5 mm RGB LED (4 team lights on base) | 4 | $0.25 | $1 |
| ESP32 DevKitC (team stations) | 2 | $5 | $10 |
| 30 mm team button on each station lid | 2 | $1 | $2 |
| Cat6 RJ45 keystone jacks (all 8 per station, ready for player buttons) | 16 | $0.80 | $12.80 |
| PL9823 5 mm RGB LED (8 player lights per station) | 16 | $0.25 | $4 |
| Perfboard, headers, wire, 1 kΩ/330 Ω/10 kΩ resistors, capacitors | 1 lot | $10 | $10 |
| 3D-printed enclosures: base + 2 stations (filament) | ~300 g | | $6 |
| 18650 cell + holder | 3 | $3.50 | $10.50 |
| USB-C UPS board (charge + boost, pass-through) | 3 | $3 | $9 |
| Slide switch, 1000 µF capacitor | 3 | $0.50 | $1.50 |
| **Stage 1 total** | | | **~$85** (~$65 without batteries, running from wall chargers) |

Even cheaper: leave the jacks and player lights out of the stations for now (−$17, so ~$70). The holes are already in the printed boxes, but you'd be soldering them in later instead of just plugging buttons in.

## Add-ons (any order)

| Add-on | What it adds | Cost |
|---|---|---|
| **Player buttons** | 30 mm arcade button + 2 m Cat6 patch cable + printed housing, plugs into any station jack | ~$3 each: ~$12 for 4 on a team, ~$24 for a full team of 8 |
| **Third team** | 1 station (ESP32, team button, 8 Cat6 jacks, 8 lights, battery + USB-C board) + enclosure | ~$27 |
| **Fourth team** | same | ~$27 |
| **Base screen** | 1.3" OLED showing team name + seat | ~$5 |
| **HDMI scoreboard box** | Raspberry Pi Zero 2 W + case, mini-HDMI cable, power, microSD | ~$35 |

## Totals
- Starter: **~$85**
- Starter + 4 player buttons on each team (2 teams x 4): **~$110**
- Max size (4 teams x 8 player buttons), base screen, batteries, HDMI box: **~$85 + $27x2 + 32 x $3 + $5 + $35 ≈ $275**

Player buttons don't light up; the light above each jack on the team station shows who buzzed. That's the cheaper option and keeps the cables to two wires.

## Suggested order
1. Starter kit; play team games with the team buttons.
2. Player buttons for both teams when you want to know who buzzed.
3. Base screen ($5) once the moderator wants the player name on the base.
4. Third and fourth stations as you grow.
5. HDMI box when you want the TV scoreboard without a laptop.
