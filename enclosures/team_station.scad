// Quiz Bowl Buzzer: team station enclosure (box + lid).
// One per team. 8 player jacks on the front with a player light (RGB LED) above
// each, USB + charger on the back, power switch on the right, and a big team
// button plus team label on the lid.
// Print the lid in the team's colour.
//
// Render one part:  openscad -D 'part="box"' -o box.stl team_station.scad
// part = "box" | "lid" | "assembly"

include <common.scad>

part       = "assembly";
team_label = "TEAM 1";     // debossed on the lid
team_num   = "1";          // large number on the lid ("" for none)

// ---- Inside cavity ----
X = 146;  // width (along the jacks)
Y = 96;   // depth
Z = 45;   // height, floor to lid underside

// ---- Player jacks (3.5 mm TRRS panel jack with M6 nut) ----
jacks       = 8;
jack_pitch  = 14;
jack_hole   = 6.2;
jack_z      = 15;
jack_labels = true;   // debossed seat numbers below each jack

// ---- Player lights (PL9823 5 mm RGB LED, pushed in from inside, one above each jack) ----
light_hole = 5.1;
light_z    = 28;      // keep below the lid lip (Z - lip_h)

// ---- Team button (30 mm snap-in arcade button, ~33 mm bezel, ~35 mm below the lid) ----
team_button   = true;
team_btn_hole = 30;               // some are 28 mm
team_btn_pos  = [112, 52];        // the area under it is kept clear

// ---- Carrier protoboard (ESP32 DevKitC + ULN2803 soldered/socketed on it) ----
// Sits on tall standoffs with the 18650 holder underneath it.
pcb_w = 90; pcb_d = 70;           // standard 70 x 90 mm protoboard
pcb_x = 2;  pcb_y = Y - 1 - pcb_d;
standoff_h = 23;

// ESP32 DevKitC (38-pin, ~55 x 28 mm) on female headers, micro-USB facing the back wall
esp_usb_x = pcb_x + 20;           // USB centre along the back wall
esp_usb_z = 36;                   // floor + standoff + board + header + DevKitC
esp_usb_w = 12; esp_usb_h = 8;    // room for a micro-USB plug overmold

// ---- 18650 holder (single cell, ~77 x 21 x 19 mm), under the protoboard, long axis front-to-back ----
batt      = true;
batt_w = 21; batt_d = 78;
batt_x = 36; batt_y = Y - 1 - batt_d;

// ---- USB-C UPS board (charger + 5 V boost with pass-through, ~30 x 25 mm), USB-C facing the back wall ----
// Runs the station from a USB-C wall charger and charges the 18650 at the same time.
chg_w = 25; chg_d = 30;
chg_x = 117; chg_y = Y - 0.5 - chg_d;
chg_led = true;                   // 3 mm window beside the USB-C for the board's charge LED
chg_pad = 2;
chg_usb_z = chg_pad + 3.2;
chg_usb_w = 12; chg_usb_h = 7;

// ---- Slide power switch (~12 x 6 mm body, 8.5 x 4 mm slot) on the right wall ----
sw_y = 45; sw_z = 24;

// ---- Lid ----
lid_led  = false;        // extra 5 mm LED on the lid (the player lights already show status)
led_hole = 5.2;
led_pos  = [X - 18, 16];

function jack_x(i) = X / 2 + (i - (jacks - 1) / 2) * jack_pitch;

module station_box() {
    shell(X, Y, Z) {
        for (i = [0 : jacks - 1]) {
            translate([jack_x(i), 1, jack_z]) rotate([90, 0, 0]) cylinder(d = jack_hole, h = wall + 2);
            translate([jack_x(i), 1, light_z]) rotate([90, 0, 0]) cylinder(d = light_hole, h = wall + 2);
            if (jack_labels) front_text(jack_x(i), jack_z - 9.5, str(i + 1), 5);
        }
        cut_back(Y, esp_usb_x, esp_usb_z, esp_usb_w, esp_usb_h);
        if (batt) {
            cut_back(Y, chg_x + chg_w / 2, chg_usb_z, chg_usb_w, chg_usb_h);
            if (chg_led) hole_back(Y, chg_x + chg_w / 2 - 11, chg_usb_z, 3);
            slide_right(X, sw_y, sw_z);
        }
    }
    pcb_standoffs(pcb_x, pcb_y, pcb_w, pcb_d, h = standoff_h, od = 6);
    if (batt) {
        retainer(batt_x, batt_y, batt_w, batt_d, h = 5);
        charger_pad(chg_x, chg_y, chg_w, chg_d, pad = chg_pad, open_side = "+y");
    }
}

module station_lid() {
    lid(X, Y, Z) {
        if (lid_led) translate([led_pos[0], led_pos[1], Z - lip_h - 1]) cylinder(d = led_hole, h = lid_t + lip_h + 2);
        if (team_button) translate([team_btn_pos[0], team_btn_pos[1], Z - 1]) cylinder(d = team_btn_hole, h = lid_t + 2);
        if (team_button) lid_text(Z, team_btn_pos[0], team_btn_pos[1] - 24, "TEAM", 6);
        text_x = team_button ? 46 : X / 2;   // shift the text left to make room for the button
        if (team_num != "") lid_text(Z, text_x, Y / 2 + 10, team_num, 34);
        lid_text(Z, text_x, 18, team_label, 9);
    }
}

if (part == "box") station_box();
else if (part == "lid") lid_for_print(X, Y, Z) station_lid();
else {
    color("lightgray") station_box();
    color("tomato") translate([0, 0, 30]) station_lid();
}
