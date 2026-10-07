# Quiz Bowl Buzzer

A wireless quiz bowl buzzer set: one ESP32 team station per team (up to 4 teams, 8 wired player buttons each) talking to an ESP32-S3 base that runs its own Wi-Fi network and serves a host page and a scoreboard.

Start with the [design doc](design/buzzer-design-v0.md).

- `design/` design doc, starter kit plan, wiring diagram, page previews
- `enclosures/` 3D-printable boxes (OpenSCAD sources and STLs), see [enclosures/README.md](enclosures/README.md)
- `firmware/base/data/` host page (`host.html`) and scoreboard (`board.html`) served by the base
