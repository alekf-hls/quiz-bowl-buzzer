# Quiz Bowl Buzzer: Design (v2)

Status: draft v2, 2026-10-10. Decisions so far (Alek):
- ESP32 wireless, on the base station's **own Wi-Fi network** (no venue Wi-Fi).
- **Team stations with wired player buttons** (one wireless box per team), chosen over a wireless buzzer per player.
- **Standard scoring**: 10 correct, 15 power, −5 neg.
- **Max size: 4 teams of up to 8 players** (32 buttons). Build target is 4 team stations.
- **Player buttons connect with Cat6 (RJ45) cables** and don't light up; the player lights on the team station show who buzzed (2026-10-10).

## 1. Goals

- Fair first-buzz detection with lockout: exact within a team, ~1 ms between teams.
- Start with 2 teams x 4 players; grow to 4 teams x 8 with no redesign.
- Host console to arm/reset, see who buzzed, and award points.
- Optional leaderboard on a laptop/TV, served by the base station.
- Few batteries, no cables across the room.

## 2. Architecture

```
 [Player button] x up to 8 --cable--> [Team station ESP32] x up to 4 --ESP-NOW--> [Base station ESP32-S3] --own Wi-Fi--> [Host view + leaderboard (browser)]
   30 mm arcade button                 detects presses, player lights,               arbitration, lockout,                  arm / score / reset,
   Cat6 cable, RJ45 plug               timestamps from Arm                           scores, web server                     projector view
```

- **Player button**: a 30 mm arcade button (no light) in a small housing, on a 2 m Cat6 patch cable with the far end cut off and soldered to the button. Only one twisted pair is used: RJ45 pin 1 (white/orange) = button signal, pin 2 (orange) = ground. Pins 3-8 are unused. No power runs to the button, so cables can be any length and swapped freely.
- **Team station**: one classic ESP32 DevKitC per team, in a box on the team's table with 8 RJ45 (Cat6 keystone) jacks, a row of 8 **player lights** (one above each jack, see §3a), a built-in **team button** on the lid (§3b), and **battery + wall power** (§3c). It is the only radio for that team.
- **Base station**: one ESP32-S3 with physical host buttons, piezo, status LEDs, a row of 4 **team lights**, a small **OLED display** (see §3a) and **battery + wall power** (§3c). Single source of truth for who buzzed first and the score.
- **Host UI**: the base serves a web page over its own network. Phone or laptop joins and opens `http://192.168.4.1`.

### Own network (SSID)
- SSID like `QuizBowl-1A2B` (last 4 of the base MAC, so two sets in one building don't clash), WPA2 password set in the host view.
- Fixed channel (default 1, changeable in the host view if the room is noisy). Team stations find the base by scanning for that SSID at power-on, lock to its channel, then talk ESP-NOW on it.
- About 10 phones/TVs can join. Team stations don't count; they don't join the network.

### Why ESP-NOW
Connectionless, ~1 ms latency, no router. With at most 8 team stations, the 20-peer ESP-NOW table isn't a constraint, and each station can be a registered, encrypted peer.

## 3. Lockout logic (fairness)

**Within a team** (on the station): every button is on its own GPIO with a hardware interrupt that records `micros()` at the instant of the press. Order between teammates is exact to microseconds; no radio involved.

**Between teams** (on the base):
1. Host presses **Arm**. Base sends `ARM{round_id}` to all stations; each records its local `micros()` at arm.
2. On the first press on a station, it sends `BUZZ{team, seat, elapsed_us}` where `elapsed_us` is time since Arm by its own clock. It retries until the base ACKs. Later presses on the same team are sent too, for stats only.
3. Base waits a **5 ms arbitration window** after the first BUZZ, then picks the lowest `elapsed_us`. Gaps under ~1 ms count as a tie, broken by arrival order.
4. Base sends `LOCK{team, seat}`. The winning player's light on the station turns on, the base's team light shows which team has it, and the base sounds the tone.
5. **Rules** (standard quiz bowl):
   - *Wrong answer*: host presses **Neg** or **Wrong**; that team is locked out for the rest of the question.
   - *Continue*: base re-arms for teams not locked out.
   - *Reset*: clears lockouts for the next toss-up.
6. Early buzz (before Arm) is ignored or flagged, configurable.

### Wireless timing reliability
- Crystal drift over a 10 s question is about 0.2 ms; Arm reaches every station within a fraction of a millisecond.
- Lost packets are retried until ACKed, so a press is never dropped silently. A station that misses Arm re-syncs and flags itself on the host view.
- Risk is a crowded 2.4 GHz room: mitigated by channel choice and a pre-game signal check per station. With only one radio per team, there's far less traffic than with a radio per player.

## 3a. Who-buzzed indicators

So the moderator can rule on a team answer without the scoreboard, and still see the player when it matters:

**Base station (which team):**
- **4 team lights** in a row, numbered 1-4, one per team station. When a team wins the buzz, its light shows that team's colour (set on the host page). Locked-out teams show dim red; Armed shows all lights soft white.
- **1.3" OLED display** (128x64) above them showing the team name and seat, e.g. `EAGLES  · seat 3`, plus question number and Armed / Locked state.

**Team station (which player):**
- **8 player lights**, one above each jack, labelled 1-8. The winning player's light turns on in the team colour, so the team and moderator can see who buzzed. The player buttons themselves don't light up; this is cheaper and keeps power off the cables.
- Between questions the lights show station status: green = connected, blinking amber = searching for base, red = low battery.

**Parts:** both rows use PL9823 5 mm addressable RGB LEDs (WS2812-type, through-hole). They daisy-chain on one data pin, so there's no extra driver chip or wire per LED, and each can show any colour. The ESP32's 3.3 V data signal is at the edge of what a 5 V chain accepts; if the lights flicker on the breadboard, add a 74AHCT125 level shifter (about $0.50) on the data line.

## 3b. Team button

Each team station has a **built-in team button** (30 mm arcade button) on its lid, for games played as a team without getting out the individual buttons.
- Wired inside the box to GPIO23, so nothing to plug in.
- Works alongside the individual buttons: whichever is pressed first counts. A team-button buzz shows as `EAGLES · team` on the base screen, host page and scoreboard, and all 8 player lights flash in the team colour.
- Team mode on the host page (optional): ignores individual buttons, for when they're plugged in but you want team-only play.

## 3c. Power: battery and wall

Every unit (base and each team station) runs from a **built-in 18650 battery and also from any USB-C wall charger**:
- An **18650 cell + USB-C "UPS" board** (charger + 5 V boost with pass-through). Plug in a USB-C charger and the unit runs from the wall while the battery charges; unplug and it carries on from the battery without restarting.
- Pick a board sold as a UPS / uninterrupted (pass-through) module, rated 5 V 1 A or more. Plain IP5306 power-bank boards can drop the output for a moment when the charger is plugged in, which would reboot the ESP32. A 1000 µF capacitor on the 5 V bus helps either way. Test plug/unplug mid-game on the breadboard.
- Estimated run time on one 3000 mAh cell: station ~12 hours, base ~8 hours (it runs the Wi-Fi network). Not yet measured.
- Battery level for every unit shows on the host page.
- Any 5 V USB-C phone charger works for wall power. The HDMI scoreboard Pi runs from the TV's USB port or its own wall charger.

## 4. Team scaling

- Each station stores its `team_id` in flash, set from the host view during pairing. Seat = jack number (1-8).
- Roster check before a game: each player presses once, and the host view marks that seat as present.
- Adding a player = plug in another button with any Cat6 cable. Adding a team = build another station and pair it.
- Team identity: coloured button caps and a coloured station lid per team.
- **Limit**: 8 players per station (a classic ESP32 has plenty of free pins); more is possible with an I/O expander. Base supports 4 teams (Alek's max); more would need more team lights.

## 5. Host console

Physical (on base): **Arm**, **Correct**, **Wrong**, **Reset**. Works with no phone at all.

Web host view: `firmware/base/data/host.html`, served at `http://192.168.4.1/` (preview: [host-preview.png](host-preview.png)).
- Who buzzed, with seat.
- Buttons: Arm, Correct (+10), Power (+15), Neg (−5), Wrong (no neg), Continue, Next question, Undo.
- **Team names and colours editable** (up to 24 characters). Changes show on the scoreboard as you type; the base saves them to flash so they survive a power cycle.
- Manual ±5 score adjust per team.
- Later: station pairing, player names per seat, signal/battery status, question timer.
- `host.html?demo` runs with no hardware and drives `board.html?demo` open in the same browser.

## 6. Scoreboard / leaderboard (optional)

- Page: `firmware/base/data/board.html`, served by the base at `http://192.168.4.1/board`. Full-screen, dark, readable across a room: team names, scores sorted high to low, who has the buzz, question number. Scores bump when they change; locked-out teams dim.
- Live updates over WebSocket (`/ws`) from the base. Open `board.html?demo` to preview with fake data and no hardware. Preview: [scoreboard-preview.png](scoreboard-preview.png).
- Scores kept in base RAM, mirrored to flash after each change so a reset doesn't lose the game. CSV export from the host view.

### Getting it on a TV
The ESP32 has no video output, so the page is shown by any device with a browser that joins the base's Wi-Fi:
- **Default: Raspberry Pi Zero 2 W on the TV's HDMI** (~$35 with case, mini-HDMI cable, power). Set up once to join `QuizBowl-XXXX` and open `/board` full-screen at boot (kiosk mode). Plug into TV and power, and the scoreboard appears, no keyboard needed.
- **Laptop on HDMI**: join the network, open `/board`, press F11.
- **Any phone, tablet or smart TV browser**: join the network and open the page. Works without HDMI.

## 7. Parts list (2 teams x 4 players, prototype)

> For the phased build (starter ~$85 with team buttons only), see [starter-kit-plan.md](starter-kit-plan.md).

| Item | Qty | Approx. each | Notes |
|---|---|---|---|
| **Per team station** | | | |
| ESP32 DevKitC (classic, 38-pin) | 2 | $5 | plenty of GPIO |
| Cat6 RJ45 keystone jack (punch-down) | 16 | $0.80 | 8 per station |
| 18650 cell + holder | 3 | $3.50 | one per station + base |
| USB-C UPS board (charge + 5 V boost, pass-through) | 3 | $3 | battery or wall power, see §3c |
| Slide power switch | 3 | $0.20 | |
| 30 mm arcade button (team button) | 2 | $1 | on each station lid |
| Enclosure | 2 | $5 | project box or 3D printed |
| **Per player button** | | | |
| 30 mm arcade button, no light | 8 | $1 | team-coloured caps |
| 2 m Cat6 patch cable | 8 | $1.50 | cut off one plug, solder pins 1 and 2 to the button |
| Small button housing | 8 | $0.50 | 3D printed |
| **Base station** | | | |
| ESP32-S3 DevKitC | 1 | $10 | |
| Piezo, 4 tactile buttons, LEDs, wire, resistors | 1 set | $5 | |
| PL9823 5 mm addressable RGB LED | 4 base + 8 per station | $0.25 | team / player lights |
| 1.3" OLED 128x64 I²C module (SH1106) | 1 | $5 | base display |
| *Optional:* Raspberry Pi Zero 2 W + case, mini-HDMI cable, 5 V supply, microSD | 1 | $35 | HDMI scoreboard box |

Rough total: **~$115** for 2 stations, 8 buttons, base with screen, and batteries. Each extra player ≈ $3; each extra team station ≈ $27.

**Full set at max size (4 teams x 8 players):** see [starter-kit-plan.md](starter-kit-plan.md), ≈ **$275** including the base screen and HDMI scoreboard box.

## 7a. Wiring

Full diagram: [wiring-diagram.svg](wiring-diagram.svg) (PNG copy: wiring-diagram.png).

**Team station (ESP32 DevKitC)**

| Jack | Button input (internal pull-up, 1 kΩ series) |
|---|---|
| 1 | GPIO13 |
| 2 | GPIO14 |
| 3 | GPIO16 |
| 4 | GPIO17 |
| 5 | GPIO18 |
| 6 | GPIO19 |
| 7 | GPIO21 |
| 8 | GPIO22 |
| Team button (on lid) | GPIO23 |

- Jack n (RJ45, T568B colours): pin 1 (white/orange) → 1 kΩ → button input; pin 2 (orange) → ground. Pins 3-8 not connected.
- Player lights: GPIO2 → 330 Ω → DIN of LED 1; DOUT → DIN chained through LED 8. Each LED: +5 V, ground, 100 nF across its power pins; one 470 µF across the 5 V bus at the chain.
- Battery sense: battery + → 100 kΩ → GPIO34 → 100 kΩ → ground.
- Power: 18650 → USB-C UPS board → on/off switch → 5 V bus (ESP32 5V pin, player lights). 1000 µF across the 5 V bus.
- The 1 kΩ resistors protect the inputs from static on long cables.
- Label the jacks "Buzzer, not network". Plugging one into a network switch by mistake won't harm either side, but it won't work.

**Base station (ESP32-S3 DevKitC)**

| Function | Pin | Wiring |
|---|---|---|
| Arm / Correct / Wrong / Reset | GPIO4 / 5 / 6 / 7 | tactile button to ground, internal pull-up |
| Buzzer | GPIO8 | 1 kΩ → 2N2222 base; active 5 V buzzer between +5 V and collector; emitter to ground |
| Armed LED (green) | GPIO9 | 220 Ω → LED → ground |
| Locked LED (red) | GPIO10 | 220 Ω → LED → ground |
| Team lights (4 x PL9823) | GPIO11 | 330 Ω → DIN of LED 1, chained; +5 V, ground, 100 nF per LED, 470 µF at the chain |
| OLED display (SH1106, I²C) | GPIO12 SDA, GPIO13 SCL | VCC 3.3 V, GND |
| Power | 18650 → USB-C UPS board → switch → 5 V pin | runs on battery or any USB-C wall charger, same as stations; 1000 µF across 5 V |

## 8. First build steps

1. **Bench radio test**: two ESP32s on USB, ESP-NOW ping-pong, measure round-trip latency.
2. **One station on a breadboard**: 2 buttons with interrupts, print press order and time-since-arm over serial.
3. **Station + base**: ARM / BUZZ / LOCK / reset messages, winner printed by the base.
4. **Fairness test**: two stations triggered from one shared button (test jig) to check tie handling and the arbitration window.
5. **Web host view** from the base (plain HTML + WebSocket, no framework), scoring and lockout rules, undo.
6. **Leaderboard page.**
7. **Hardware build-out**: Cat6 cabling, button housings, station enclosures, batteries; then the second team.

## 9. Software layout (proposed repo)

```
firmware/
  common/protocol.h      # message types, shared constants
  station/               # PlatformIO project, ESP32 team station
  base/                  # PlatformIO project, ESP32-S3 base
    data/                # host + board web pages (LittleFS)
docs/
  design.md              # this file
```

PlatformIO + Arduino framework to keep it approachable.

## 10. Repository

Everything here is mirrored to GitHub: alekf-hls/quiz-bowl-buzzer (main).

## 12. Enclosure dimensions for indicators (check against the parts you buy)

| Part | Where | Size | Mounting |
|---|---|---|---|
| 30 mm arcade button (team button) | each station lid | 30 mm snap-in body, ~33 mm bezel | 30 mm hole (some are 28 mm; check part) |
| 18650 cell in holder | base and each station | holder ~77 x 21 x 19 mm | internal clip or screw bosses |
| USB-C UPS board | base and each station | typically ~30 x 25 mm, USB-C on one edge | USB-C cutout ~10 x 4.5 mm in the wall; status LED window if the board has one |
| Slide power switch | base and each station | ~12 x 6 mm body | ~8.5 x 4 mm slot |
| PL9823 5 mm LED | base (x4), each station (x8) | 5 mm dome, ~8.6 mm long body, 4 leads | 5.1 mm hole; base row at 15 mm pitch; station one directly above each jack |
| 1.3" OLED module (SH1106) | base | PCB ~35.5 x 33.5 mm, ~4 mm thick plus header; visible area ~30 x 15 mm | window ~31 x 16 mm, 4 x M2 holes ~30.5 mm apart |
| Cat6 RJ45 keystone jack | each station (x8) | ~14.5 x 16 x 30 mm body, snap-in | standard keystone cutout ~14.9 x 19.2 mm in a 1.5-2 mm thick wall; ~20 mm minimum pitch, so 8 fit best as 2 rows of 4 |
| Cat6 cable at the button | each player button | ~6 mm cable | 6.5 mm hole with strain relief (knot or zip-tie inside) |
| 30 mm arcade button | each player button | 30 mm snap-in | 30 mm hole |
| Label strip | base and station | numbers 1-8 under each light | embossed or printed |
