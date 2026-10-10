// Quiz Bowl Buzzer: team station enclosure (box + lid).
// One per team. 8 Cat6 (RJ45 keystone) player jacks on the front with a player light (RGB LED) above
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
X = 174;  // width (along the jacks)
Y = 113;  // depth (keystone jacks reach ~32 mm into the box)
Z = 45;   // height, floor to lid underside

// ---- Player jacks ----
// "keystone": snap-in RJ45 (Cat6) keystone jacks. Cut-out 14.9 x 19.2 mm, wall thinned
//             to 2.0 mm around it so the latch clicks in; ~32 mm deep behind the wall.
// "trrs":     3.5 mm TRRS panel jacks with a nut (6.2 mm hole). Set jack_pitch = 14.
jack_type   = "keystone";
jacks       = 8;
jack_pitch  = 20;
jack_z      = 14;     // centre height above the floor
keystone_cut   = [14.9, 19.2];
keystone_panel = 2.0;
jack_hole   = 6.2;    // TRRS only
jack_labels = true;   // debossed seat numbers above each light

// ---- Player lights (PL9823 5 mm RGB LED, pushed in from inside, one above each jack) ----
light_hole = 5.1;
light_z    = 30;      // keep below the lid lip (Z - lip_h)
label_z    = 37;

// ---- Team button (30 mm snap-in arcade button, ~33 mm bezel, ~35 mm below the lid) ----
team_button   = true;
team_btn_hole = 30;               // some are 28 mm
team_btn_pos  = [126, 62];        // the area under it is kept clear

// ---- Carrier protoboard (ESP32 DevKitC soldered/socketed on it) ----
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
chg_x = X - 4 - chg_w; chg_y = Y - 0.5 - chg_d;
chg_led = true;                   // 3 mm window beside the USB-C for the board's charge LED
chg_pad = 2;
chg_usb_z = chg_pad + 3.2;
chg_usb_w = 12; chg_usb_h = 7;

// ---- Slide power switch (~12 x 6 mm body, 8.5 x 4 mm slot) on the right wall ----
sw_y = 50; sw_z = 24;

// ---- Lid ----
lid_led  = false;        // extra 5 mm LED on the lid (the player lights already show status)
led_hole = 5.2;
led_pos  = [X - 18, 16];

function jack_x(i) = X / 2 + (i - (jacks - 1) / 2) * jack_pitch;

module station_box() {
    shell(X, Y, Z) {
        for (i = [0 : jacks - 1]) {
            if (jack_type == "keystone") {
                translate([jack_x(i) - keystone_cut[0] / 2, -wall - 1, jack_z - keystone_cut[1] / 2])
                    cube([keystone_cut[0], wall + 2, keystone_cut[1]]);
                // thin the wall from inside around the cut-out
                translate([jack_x(i) - keystone_cut[0] / 2 - 1.5, -(wall - keystone_panel), jack_z - keystone_cut[1] / 2 - 1.5])
                    cube([keystone_cut[0] + 3, wall - keystone_panel + 0.01, keystone_cut[1] + 3]);
            } else
                translate([jack_x(i), 1, jack_z]) rotate([90, 0, 0]) cylinder(d = jack_hole, h = wall + 2);
            translate([jack_x(i), 1, light_z]) rotate([90, 0, 0]) cylinder(d = light_hole, h = wall + 2);
            if (jack_labels) front_text(jack_x(i), jack_type == "keystone" ? label_z : jack_z - 9.5, str(i + 1), 5);
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
