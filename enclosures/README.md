# Quiz Bowl Buzzer enclosures

Parametric OpenSCAD (tested with OpenSCAD 2021.01) plus ready-to-print STLs for:

| Part | File | Outer size (W x D x H) |
|---|---|---|
| Team station box | `stl/team_station_box.stl` | 151 x 101 x 58 mm |
| Team station lid | `stl/team_station_lid.stl` | 151 x 101 x 3 mm (+4 mm lip) |
| Base station box | `stl/base_station_box.stl` | 180 x 125 x 47 mm |
| Base station lid | `stl/base_station_lid.stl` | 180 x 125 x 3 mm (+4 mm lip) |

Fits a 180 x 180 mm bed or larger. Previews are in `preview/`.

## What's where

**Team station** (one per team)
- Front: 8 holes for 3.5 mm TRRS panel jacks, a player light (5 mm RGB LED) above each one, seat numbers 1-8 below.
- Back: ESP32 USB opening and the charger board's USB-C opening.
- Right side: snap-in rocker power switch.
- Lid: a 60 mm team button (for playing as a team without the player buttons), big team number and "TEAM n" label. Print the lid in the team's colour. `team_button = false` removes the button hole. (`lid_led = true` adds an extra LED hole on the lid.)
- Inside: 4 tall (25 mm) standoffs for a 70 x 90 mm protoboard carrying the ESP32 DevKitC and ULN2803, with the 18650 holder in rails underneath it; a raised pocket for the IP5306 charge/boost board. The area under the team button is kept clear down to the floor.

**Base station**
- Lid, front to back: Arm / Correct / Wrong / Reset buttons with labels; a row of 4 team lights (5 mm RGB LEDs) numbered 1-4 (`teams` sets the count); the 1.3" OLED window (chamfered, with 4 M2 standoffs underneath for the module), Armed and Locked LEDs to its left and the buzzer grille with a glue-in ring to its right.
- Back: ESP32-S3 USB opening (wide enough for both USB-C ports).
- Right side: charger USB-C and rocker power switch.
- Inside: same protoboard standoffs, 18650 rails along the back wall, charger board pocket.

## Changing it

Open `team_station.scad` or `base_station.scad`; everything is a named variable at the top. Common ones:

- `team_label`, `team_num`: lid text per team (e.g. `openscad -D 'team_num="3"' -D 'team_label="TEAM 3"' -D 'part="lid"' -o lid3.stl team_station.scad`).
- `jacks`: number of player jacks (the box doesn't shrink automatically; reduce `X` too if you want a smaller box).
- `batt = false`: USB-only, drops the battery rails, charger pocket, switch and charger opening.
- `btn_hole`: host button hole size (24.2 for 24 mm arcade, 16.2 or 12.2 for panel-mount momentaries).
- `screw_mode` in `common.scad`: `"selftap"` (M3 straight into plastic) or `"insert"` (M3 heat-set inserts).

Export: `openscad -D 'part="box"' -o box.stl team_station.scad` and the same with `part="lid"`. `part="assembly"` shows both.

## Assumed part dimensions (measure yours before printing)

| Part | Assumed | Where it matters |
|---|---|---|
| ESP32 DevKitC 38-pin | ~55 x 28 mm, micro-USB on a short end | USB opening centred 22 mm from the left inner wall |
| ESP32-S3 DevKitC-1 | ~63 x 26 mm, two USB-C on a short end | 24 x 8 mm opening at the same height |
| Board stack | standoff (25 mm station, 5 mm base) + 1.6 mm protoboard + 8.5 mm female header + DevKitC | sets the USB height (`esp_usb_z`: 38 mm station, 18 mm base) |
| Team button | 60 mm arcade button with LED, 28-30 mm mounting hole, ~52 mm below the panel with microswitch | 29 mm hole; sets the station's 56 mm inner height |
| Protoboard | 70 x 90 mm, M2 holes 2 mm in from each corner | standoff positions (M2 self-tap pilot) |
| 3.5 mm TRRS panel jack | M6 thread with nut, ~12 mm deep behind the panel | 6.3 mm holes in a 2.4 mm wall |
| Player / team lights | PL9823 5 mm RGB LED, pushed in from inside (flange stops it) | 5.2 mm holes; station lights 13 mm above the jacks, base lights 28 mm apart |
| OLED | 1.3" SH1106 128x64 I2C module, PCB 35.4 x 33.5 mm, M2 holes 30.4 x 28.5 mm, glass centred ~1.5 mm off the PCB centre | 31 x 17 mm window; check `oled_pcb_dy` and `oled_holes` against your module, they vary between sellers |
| 18650 holder | single cell, ~77 x 21 x 19 mm | retaining rails, fix with double-sided tape |
| IP5306 charge/boost board | ~26 x 21.5 mm, USB-C on a short end in both boxes | pocket and 12 x 7 mm opening; these boards vary a lot, measure yours |
| Rocker switch | KCD11 mini, 19 x 13 mm cut-out | wall thinned to 1.6 mm around it so the clips grip |
| Host buttons | 24 mm snap-in arcade buttons, ~33 mm deep with microswitch | 45 mm inner height; the design doc listed tactile switches, change `btn_hole` if you stay with those |
| Buzzer | 12 mm round active 5 V buzzer | glue-in ring under the lid |
| Armed / Locked LEDs | 5 mm | 5.2 mm holes, press fit or glue |

## Power

Every unit charges its 18650 and runs from any USB-C phone charger through the charger board's USB-C port on the outside, and runs on the battery when unplugged. The ESP32's own USB port is also reachable, for firmware updates.

## Printing

- PLA or PETG, 0.2 mm layers, 3 walls, 15-20 % infill, no supports needed.
- Box prints opening up. Lid STLs are already flipped so the top face is on the bed (labels print as clean recesses).
- If holes come out tight, drill them to size; jack and switch holes are the ones that matter.

## Hardware per enclosure

- 4 x M3 x 10 mm screws for the lid (or 4 x M3 heat-set inserts with `screw_mode = "insert"`).
- 4 x M2 x 5 mm self-tapping screws for the protoboard (base: 4 more for the OLED).
- 4 stick-on rubber feet.
