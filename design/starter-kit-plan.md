# Quiz Bowl Buzzer: Starter Kit and Add-ons

Date: 2026-10-07. Prices are rough single-unit online prices (AliExpress/Amazon); they'll vary.
Goal: a cheap set you can play with now, and add to without rebuilding anything.

## Rules that keep add-ons cheap
- **Drill/print for the max from day one.** Every team station gets all 8 jack holes and 8 player-light holes even if only 4 buttons exist. Jacks and lights cost under $0.70 per seat, so fit them all.
- **Use 4-wire TRRS cables from the start**, even on buttons without lights, so lit buttons can plug in later.
- **Firmware detects what's fitted**: no OLED, no ULN2803, any number of stations (1-4) all just work.
- **Battery + wall power is built in from the start** (Alek's ask). To save ~$20 you can skip the batteries at first and run every unit from a USB-C wall charger; the board and USB-C socket are the same either way.
- **Any phone or laptop is the scoreboard** until you want a dedicated HDMI box.

## Stage 1: Starter kit, 2 teams x 4 players (~$85)
Everything needed to run a real game: lockout, scoring, host page, scoreboard in a browser, which-team lights on the base, which-player lights on the stations, a team button on each station, and USB-C rechargeable batteries that also run from wall power.

| Item | Qty | Each | Total |
|---|---|---|---|
| ESP32-S3 DevKitC (base) | 1 | $10 | $10 |
| Base parts: 4 tactile buttons, active buzzer, 2N2222, 2 LEDs, resistors | 1 set | $5 | $5 |
| PL9823 5 mm RGB LED (4 team lights on base) | 4 | $0.25 | $1 |
| ESP32 DevKitC (team stations) | 2 | $5 | $10 |
| TRRS panel jacks (all 8 per station) | 16 | $0.40 | $6.40 |
| PL9823 5 mm RGB LED (8 player lights per station) | 16 | $0.25 | $4 |
| 30 mm arcade button, no light | 8 | $1 | $8 |
| 2 m TRRS cable (cut one end into button) | 8 | $2 | $16 |
| Perfboard, headers, wire, 1 kΩ/330 Ω resistors, capacitors | 1 lot | $10 | $10 |
| 3D-printed enclosures: base, 2 stations, 8 button housings (filament) | ~400 g | | $8 |
| 18650 cell + holder | 3 | $3.50 | $10.50 |
| USB-C UPS board (charge + boost, pass-through) | 3 | $3 | $9 |
| Slide switch, 1000 µF capacitor | 3 | $0.50 | $1.50 |
| 30 mm team button on each station lid | 2 | $1 | $2 |
| **Stage 1 total** | | | **~$105** (~$85 without batteries, running from wall chargers) |

## Add-on stages (any order)

| Stage | What it adds | Cost |
|---|---|---|
| **2. Fill out teams** | 4 more buttons per team (2 teams x 8 players) | ~$14 per team (4 x $3.50: button, cable, printed housing) |
| **3. Third team** | 1 station (ESP32, 8 jacks, 8 lights, team button, battery + USB-C board) + enclosure + 4 buttons | ~$38 |
| **3b. Fourth team** | same | ~$38 |
| **4. Full teams 3 and 4** | 4 more buttons each | ~$14 per team |
| **5. Base screen** | 1.3" OLED showing team name + seat | ~$5 |
| **7. HDMI scoreboard box** | Raspberry Pi Zero 2 W + case, mini-HDMI cable, power, microSD | ~$35 |
| **8. Lit buttons (optional)** | ULN2803 per station + 60 mm LED arcade buttons | ~$1 per station + $3 per button |

## Totals
- Starter (Stage 1): **~$105**
- Max size (4 teams x 8), screen, batteries, HDMI box, without lit buttons: **~$105 + $14x2 + $38x2 + $14x2 + $5 + $35 ≈ $280**
- Adding lit buttons on top: **~+$100** (32 buttons + 4 driver chips).

**Recommendation:** skip lit buttons. The player light above each jack already shows who buzzed, and lit 60 mm buttons were the single biggest cost in the full set. If you do want them, buy 60 mm LED buttons from the start rather than replacing the 30 mm ones.

## Suggested order
1. Stage 1, then play a few games.
2. Stage 5 (base screen, $5) once the moderator wants the player name without looking at the stations.
3. Stages 2-4 as your teams grow.
4. Stage 7 when you want the TV scoreboard without a laptop.
