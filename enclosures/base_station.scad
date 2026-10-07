// Quiz Bowl Buzzer: base (host) station enclosure (box + lid).
// Four host buttons (Arm / Correct / Wrong / Reset) along the front of the lid,
// a row of team lights (RGB LEDs, one per team) above them, then the OLED window flanked by
// the Armed/Locked LEDs and the buzzer grille. USB on the back wall,
// charger USB-C and power switch on the right wall.
//
// Render one part:  openscad -D 'part="box"' -o box.stl base_station.scad
// part = "box" | "lid" | "assembly"

include <common.scad>

part = "assembly";

// ---- Inside cavity ----
X = 175;
Y = 120;
Z = 45;   // deep enough for 24 mm arcade buttons with microswitches (~33 mm below the lid)

// ---- Host buttons ----
// Default: 24 mm snap-in arcade buttons (hole 24 mm). For 12 mm or 16 mm panel-mount
// momentary buttons set btn_hole to 12.2 or 16.2.
btn_labels = ["ARM", "CORRECT", "WRONG", "RESET"];
btn_hole   = 24.2;
btn_pitch  = 40;
btn_y      = 36;
btn_label_y = 12;

// ---- Team lights (PL9823 5 mm RGB LED, one per team station), numbered 1-n ----
teams       = 4;
light_hole  = 5.2;
light_pitch = 28;
light_y     = 62;
light_label_y = 71;

// ---- OLED (1.3" SH1106 128x64 I2C module, PCB ~35.4 x 33.5 mm) ----
// Window over the glass; the module screws to 4 standoffs under the lid (M2).
oled_center = [X / 2, 93];       // centre of the visible window
oled_win    = [31, 17];          // window (active area is ~29.4 x 14.7)
oled_pcb    = [35.4, 33.5];
oled_holes  = [30.4, 28.5];      // M2 hole spacing on the module
oled_pcb_dy = 1.5;               // PCB centre offset from window centre (+y = toward back)
oled_glass_t = 3.2;              // standoff height: glass + tape, so the glass sits just under the lid

// ---- Status LEDs (5 mm): Armed (green), Locked (red) ----
led_hole   = 5.2;
led_labels = ["ARMED", "LOCKED"];
led_y      = 97;
led_x0     = 22;
led_pitch  = 22;

// ---- Buzzer (12 mm round active buzzer), glued into a ring under a grille ----
piezo_d   = 12.4;
piezo_pos = [X - 30, 95];

// ---- Carrier protoboard with the ESP32-S3 DevKitC, USB-C facing the back wall ----
pcb_w = 90; pcb_d = 70;
pcb_x = 2;  pcb_y = Y - 1 - pcb_d;
standoff_h = 5;
esp_usb_x = pcb_x + 20;
esp_usb_z = 18;
esp_usb_w = 24; esp_usb_h = 8;   // the S3 DevKitC has two USB-C ports side by side

// ---- Optional 18650 + IP5306 charge/boost board (set batt = false to run from USB only) ----
batt = true;
batt_w = 78; batt_d = 21;               // holder lies along the back wall
batt_x = X - 1 - batt_w; batt_y = Y - 1 - batt_d;
chg_w = 26; chg_d = 21.5;               // IP5306 board along x, USB-C facing the right wall
chg_x = X - 0.5 - chg_w; chg_y = 64;
chg_pad = 2;
chg_usb_z = chg_pad + 3.2;
sw_y = 52; sw_z = 22;

function btn_x(i) = X / 2 + (i - (len(btn_labels) - 1) / 2) * btn_pitch;
function led_x(i) = led_x0 + i * led_pitch;
function light_x(i) = X / 2 + (i - (teams - 1) / 2) * light_pitch;
function oled_hole_pts() = [for (sx = [-1, 1], sy = [-1, 1])
    [oled_center[0] + sx * oled_holes[0] / 2, oled_center[1] + oled_pcb_dy + sy * oled_holes[1] / 2]];

module base_box() {
    shell(X, Y, Z) {
        cut_back(Y, esp_usb_x, esp_usb_z, esp_usb_w, esp_usb_h);
        if (batt) {
            cut_right(X, chg_y + chg_d / 2, chg_usb_z, 12, 7);
            rocker_right(X, sw_y, sw_z);
        }
    }
    pcb_standoffs(pcb_x, pcb_y, pcb_w, pcb_d, h = standoff_h);
    if (batt) {
        retainer(batt_x, batt_y, batt_w, batt_d, h = 5);
        charger_pad(chg_x, chg_y, chg_w, chg_d, pad = chg_pad, open_side = "+x");
    }
}

module base_lid() {
    difference() {
        union() {
            lid(X, Y, Z) {
                for (i = [0 : len(btn_labels) - 1]) {
                    translate([btn_x(i), btn_y, Z - 1]) cylinder(d = btn_hole, h = lid_t + 2);
                    lid_text(Z, btn_x(i), btn_label_y, btn_labels[i], 5.5);
                }
                for (i = [0 : len(led_labels) - 1]) {
                    translate([led_x(i), led_y, Z - 1]) cylinder(d = led_hole, h = lid_t + 2);
                    lid_text(Z, led_x(i), led_y - 8, led_labels[i], 3.5);
                }
                for (i = [0 : teams - 1]) {
                    translate([light_x(i), light_y, Z - 1]) cylinder(d = light_hole, h = lid_t + 2);
                    lid_text(Z, light_x(i), light_label_y, str(i + 1), 4.5);
                }
                // OLED window, chamfered on top so it reads at an angle
                translate([oled_center[0], oled_center[1], Z - 1]) hull() {
                    translate([0, 0, 0.5]) cube([oled_win[0], oled_win[1], 1], center = true);
                    translate([0, 0, 1 + lid_t]) cube([oled_win[0] + 2 * lid_t, oled_win[1] + 2 * lid_t, 0.02], center = true);
                }
                // piezo grille: centre hole + ring of 6
                translate([piezo_pos[0], piezo_pos[1], Z - 1]) {
                    cylinder(d = 2, h = lid_t + 2);
                    for (a = [0 : 60 : 300]) rotate(a) translate([3.6, 0, 0]) cylinder(d = 1.8, h = lid_t + 2);
                }
            }
            // OLED standoffs (M2 self-tap) under the lid
            for (p = oled_hole_pts()) translate([p[0], p[1], Z - oled_glass_t]) difference() {
                cylinder(d = 4.5, h = oled_glass_t + 0.01);
                translate([0, 0, -1]) cylinder(d = 1.8, h = oled_glass_t);
            }
            // ring under the lid that the piezo glues into
            translate([piezo_pos[0], piezo_pos[1], Z - 3]) difference() {
                cylinder(d = piezo_d + 2.4, h = 3.01);
                translate([0, 0, -1]) cylinder(d = piezo_d, h = 5);
            }
        }
    }
}

if (part == "box") base_box();
else if (part == "lid") lid_for_print(X, Y, Z) base_lid();
else {
    color("lightgray") base_box();
    color("steelblue") translate([0, 0, 30]) base_lid();
}
