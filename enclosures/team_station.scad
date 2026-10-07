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
Z = 56;   // height, floor to lid underside: the 60 mm team button hangs ~52 mm below the lid

// ---- Player jacks (3.5 mm TRRS panel jack with M6 nut) ----
jacks       = 8;
jack_pitch  = 14;
jack_hole   = 6.3;
jack_z      = 15;
jack_labels = true;   // debossed seat numbers below each jack

// ---- Player lights (PL9823 5 mm RGB LED, pushed in from inside, one above each jack) ----
light_hole = 5.2;
light_z    = 28;      // keep below the lid lip (Z - lip_h)

// ---- Team button (60 mm arcade button with LED, 28-30 mm mounting hole) ----
team_button   = true;
team_btn_hole = 29;
team_btn_pos  = [112, 50];        // the area under it is kept clear down to the floor

// ---- Carrier protoboard (ESP32 DevKitC + ULN2803 soldered/socketed on it) ----
// Sits on tall standoffs with the 18650 holder underneath it.
pcb_w = 90; pcb_d = 70;           // standard 70 x 90 mm protoboard
pcb_x = 2;  pcb_y = Y - 1 - pcb_d;
standoff_h = 25;

// ESP32 DevKitC (38-pin, ~55 x 28 mm) on female headers, micro-USB facing the back wall
esp_usb_x = pcb_x + 20;           // USB centre along the back wall
esp_usb_z = 38;                   // floor + standoff + board + header + DevKitC
esp_usb_w = 12; esp_usb_h = 8;    // room for a micro-USB plug overmold

// ---- 18650 holder (single cell, ~77 x 21 x 19 mm), under the protoboard, long axis front-to-back ----
batt      = true;
batt_w = 21; batt_d = 78;
batt_x = 36; batt_y = Y - 1 - batt_d;

// ---- IP5306 USB-C charge/boost board (~26 x 21 mm assumed), USB-C facing the back wall ----
chg_w = 21.5; chg_d = 26;
chg_x = 121; chg_y = Y - 0.5 - chg_d;
chg_pad = 2;
chg_usb_z = chg_pad + 3.2;
chg_usb_w = 12; chg_usb_h = 7;

// ---- Power rocker switch (KCD11 mini, 19 x 13 mm cut-out) on the right wall ----
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
            rocker_right(X, sw_y, sw_z);
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
