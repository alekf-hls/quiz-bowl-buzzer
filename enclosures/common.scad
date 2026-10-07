// Quiz Bowl Buzzer: shared enclosure helpers.
// Coordinates: the inside cavity spans [0,X] x [0,Y], the floor's top face is z=0,
// and the lid's underside sits at z=Z. y=0 is the front wall.

$fn = 48;

// ---- Shell ----
wall       = 2.4;   // side wall thickness
floor_t    = 2.4;   // floor thickness
lid_t      = 3.0;   // lid plate thickness
corner_r   = 5;     // outer corner radius
lip_h      = 4;     // lid locating lip depth
lip_w      = 1.6;   // lid lip thickness
lip_clear  = 0.3;   // gap between lip and wall (per side)

// ---- Lid screws (4 corners) ----
boss_d       = 8;   // corner boss diameter
boss_off     = 3.6; // boss centre from inner walls
screw_mode   = "selftap"; // "selftap" (M3 into plastic) or "insert" (M3 heat-set insert)
pilot_d      = (screw_mode == "insert") ? 4.0 : 2.6;
pilot_depth  = 10;
screw_clear  = 3.4; // M3 clearance hole in lid
screw_head_d = 6.2; // M3 head counterbore
screw_head_h = 1.6;

// ---- Text ----
font      = "Liberation Sans:style=Bold";
deboss    = 0.6;

module rrect(x, y, h, r) {
    // rounded rectangle from [0,0] to [x,y], height h
    hull() for (px = [r, x - r], py = [r, y - r])
        translate([px, py, 0]) cylinder(r = r, h = h);
}

function boss_pts(X, Y) = [[boss_off, boss_off], [X - boss_off, boss_off],
                           [boss_off, Y - boss_off], [X - boss_off, Y - boss_off]];

// Open-top box shell with corner bosses. Children are subtracted (cut-outs).
module shell(X, Y, Z) {
    difference() {
        union() {
            difference() {
                translate([-wall, -wall, -floor_t])
                    rrect(X + 2 * wall, Y + 2 * wall, Z + floor_t, corner_r);
                rrect(X, Y, Z + 1, max(corner_r - wall, 0.5));
            }
            for (p = boss_pts(X, Y)) translate([p[0], p[1], 0]) {
                cylinder(d = boss_d, h = Z);
                // fill boss to the walls so it prints without overhang gaps
                translate([p[0] < X / 2 ? -boss_off : 0, p[1] < Y / 2 ? -boss_off : 0, 0])
                    cube([boss_off, boss_off, Z]);
            }
        }
        for (p = boss_pts(X, Y)) translate([p[0], p[1], Z - pilot_depth]) cylinder(d = pilot_d, h = pilot_depth + 1);
        children();
    }
}

// Lid in assembled orientation (plate from Z to Z+lid_t, lip hanging below).
// Children are subtracted (holes, text).
module lid(X, Y, Z) {
    difference() {
        union() {
            translate([-wall, -wall, Z]) rrect(X + 2 * wall, Y + 2 * wall, lid_t, corner_r);
            translate([0, 0, Z - lip_h]) difference() {
                translate([lip_clear, lip_clear, 0]) rrect(X - 2 * lip_clear, Y - 2 * lip_clear, lip_h, max(corner_r - wall - lip_clear, 0.5));
                translate([lip_clear + lip_w, lip_clear + lip_w, -1]) cube([X - 2 * (lip_clear + lip_w), Y - 2 * (lip_clear + lip_w), lip_h + 2]);
                for (p = boss_pts(X, Y)) translate([p[0], p[1], -1]) cylinder(d = boss_d + 2 * boss_off + 1, h = lip_h + 2);
            }
        }
        for (p = boss_pts(X, Y)) translate([p[0], p[1], Z - 1]) {
            cylinder(d = screw_clear, h = lid_t + 2);
            translate([0, 0, 1 + lid_t - screw_head_h]) cylinder(d = screw_head_d, h = screw_head_h + 1);
        }
        children();
    }
}

// ---- Interior fittings ----

// Standoffs for a rectangular PCB/protoboard: board footprint w x d at (x0,y0),
// holes inset `inset` from each corner, M2 self-tap pilot.
module pcb_standoffs(x0, y0, w, d, inset = 2, h = 5, od = 5, pilot = 1.8) {
    for (px = [x0 + inset, x0 + w - inset], py = [y0 + inset, y0 + d - inset])
        translate([px, py, 0]) difference() {
            cylinder(d = od, h = h);
            translate([0, 0, 0.6]) cylinder(d = pilot, h = h);
        }
}

// Low rails around a rectangular part so it can be taped/glued in place.
module retainer(x0, y0, w, d, h = 4, t = 1.6, clear = 0.4, open_side = "") {
    difference() {
        translate([x0 - clear - t, y0 - clear - t, 0]) cube([w + 2 * (clear + t), d + 2 * (clear + t), h]);
        translate([x0 - clear, y0 - clear, -1]) cube([w + 2 * clear, d + 2 * clear, h + 2]);
        // open one side (e.g. the side a connector faces)
        if (open_side == "+y") translate([x0, y0 + d - 1, -1]) cube([w, 10, h + 2]);
        if (open_side == "+x") translate([x0 + w - 1, y0, -1]) cube([10, d, h + 2]);
        // finger notches on the long sides for removal
        translate([x0 + w / 2 - 6, y0 - 10, 1.5]) cube([12, d + 20, h]);
    }
}

// Raised pad with rails for a USB-C charger / UPS board.
module charger_pad(x0, y0, w, d, pad = 2, open_side = "+y") {
    translate([x0 - 2, y0 - 2, 0]) cube([w + 4, d + 4, pad]);
    translate([0, 0, pad]) retainer(x0, y0, w, d, h = 2.5, open_side = open_side);
}

// Rectangular hole through the back wall (y = Y), centred at (x, z).
module cut_back(Y, x, z, w, h, r = 1) {
    translate([x - w / 2, Y - 1, z - h / 2]) cube([w, wall + 2, h]);
}
// Rectangular hole through the right wall (x = X), centred at (y, z).
module cut_right(X, y, z, w, h) {
    translate([X - 1, y - w / 2, z - h / 2]) cube([wall + 2, w, h]);
}

// Snap-in rocker switch cut-out in the right wall, with the wall thinned around it
// from inside so the snap tabs can grip.
module rocker_right(X, y, z, w = 19.2, h = 13.0, panel = 1.6) {
    cut_right(X, y, z, w, h);
    translate([X - 0.01, y - w / 2 - 3, z - h / 2 - 3])
        cube([wall - panel + 0.01, w + 6, h + 6]);
}

// Slide power switch in the right wall: slot for the actuator plus two M2 screw
// holes either side (typical 12 x 6 mm body, screw holes 15 mm apart).
module slide_right(X, y, z, slot = [8.5, 4.2], screw_pitch = 15, screw_d = 2.2) {
    cut_right(X, y, z, slot[0] + 0.4, slot[1] + 0.4);
    for (s = [-1, 1]) translate([X - 1, y + s * screw_pitch / 2, z]) rotate([0, 90, 0]) cylinder(d = screw_d, h = wall + 2);
}

// Small round window in the back wall (y = Y), e.g. for a charge LED.
module hole_back(Y, x, z, d = 3) {
    translate([x, Y - 1, z]) rotate([-90, 0, 0]) cylinder(d = d, h = wall + 2);
}

// Debossed text on the front outer wall face (y = -wall), centred at (x, z).
module front_text(x, z, s, size = 5) {
    translate([x, -wall + deboss, z]) rotate([90, 0, 0])
        linear_extrude(deboss + 1) text(s, size = size, font = font, halign = "center", valign = "center");
}

// Debossed text on the lid top (z = Z + lid_t), centred at (x, y).
module lid_text(Z, x, y, s, size = 5) {
    translate([x, y, Z + lid_t - deboss]) linear_extrude(deboss + 1)
        text(s, size = size, font = font, halign = "center", valign = "center");
}

// Lid ready to print: flipped so the top face lies on the bed.
module lid_for_print(X, Y, Z) {
    translate([0, Y, Z + lid_t]) rotate([180, 0, 0]) children();
}
