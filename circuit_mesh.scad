// ============================================
// Poke-Through Prototyping Board
// ============================================

// --- Hammond die-cast enclosure preset ---
// Options: "1590A"  (92.5 × 38.5 mm outer, 31 mm deep)
//          "1590B"  (112  × 60   mm outer, 31 mm deep)
//          "1590BB" (119  × 94   mm outer, 34 mm deep)
//          "125B"   (121  × 66   mm outer, 39 mm deep)
//          "custom" — enter your own dimensions in custom_board_width / custom_board_depth
preset = "custom"; // [1590A, 1590B, 1590BB, 125B, custom]

// Wall thickness of Hammond enclosure — subtract from outer dimensions to get inner space
// Typical die-cast boxes: 1.5mm per side = 3mm total reduction
enclosure_wall_thick = 1.5;  // mm — adjust if your enclosure has different wall thickness

// Board footprint — edit these only when preset = "custom":
custom_board_width = 80;  // mm
custom_board_depth = 60;  // mm

// Outer dimensions of Hammond boxes (from specifications)
outer_board_width = preset == "1590A"  ?  92.5 :
                    preset == "1590B"  ? 112   :
                    preset == "1590BB" ? 119   :
                    preset == "125B"   ? 121   :
                    custom_board_width;

outer_board_depth = preset == "1590A"  ?  38.5 :
                    preset == "1590B"  ?  60   :
                    preset == "1590BB" ?  94   :
                    preset == "125B"   ?  66   :
                    custom_board_depth;

// Subtract wall thickness on both sides (2 × wall_thick) to get dimensions that fit inside
is_custom = preset == "custom";
board_width = is_custom ? outer_board_width : (outer_board_width - 2*enclosure_wall_thick);
board_depth = is_custom ? outer_board_depth : (outer_board_depth - 2*enclosure_wall_thick);

// Enclosure interior height — informational reference, not used in board geometry.
// Tells you how much vertical clearance the chosen Hammond box provides.
enclosure_height = preset == "1590A"  ? 31 :
                   preset == "1590B"  ? 31 :
                   preset == "1590BB" ? 34 :
                   preset == "125B"   ? 39 :
                   0;   // 0 = no preset selected

board_thick  = 2.5;   // mm — thicker = more grip, harder to insert (2.0mm for lighter builds)

hole_dia     = 1.2;   // mm — tuning per material and printer:
                      // TPU: 0.85mm | PETG: 1.2–2.0mm | PLA: 1.0–1.2mm
                      // Larger holes prevent tight insertion and allow easy lead bending
pitch        = 2.54;  // mm — standard component pitch, don't change unless needed

margin       = 5;     // mm — border around the hole grid

corner_radius = 5;    // mm — round the board corners to fit rounded Hammond enclosures

// --- Mounting screw holes ---
add_screw_holes    = true;
screw_dia          = 3.2;  // mm — M3 clearance
screw_margin       = 4;    // mm — distance from corner to screw center
countersink_dia    = 6.0;  // mm — M3 flat head countersink diameter
countersink_depth  = 1.5;  // mm — depth of countersink recess

// ============================================
// Derived values (don't edit)
cols = floor((board_width  - margin*2) / pitch);
rows = floor((board_depth - margin*2) / pitch);

// Center the grid on the board
x_offset = (board_width  - (cols - 1) * pitch) / 2;
y_offset = (board_depth - (rows - 1) * pitch) / 2;

// Corner screw positions
screw_positions = [
    [screw_margin,               screw_margin],
    [board_width - screw_margin, screw_margin],
    [screw_margin,               board_depth - screw_margin],
    [board_width - screw_margin, board_depth - screw_margin]
];

// ============================================
// Build it

difference() {
    // Base plate with rounded corners
    linear_extrude(board_thick) {
        offset(r=corner_radius, $fn=20) {
            square([board_width - 2*corner_radius, board_depth - 2*corner_radius]);
        }
    }

    // Grid of holes
    for (x = [0 : cols-1]) {
        for (y = [0 : rows-1]) {
            translate([
                x_offset + x * pitch,
                y_offset + y * pitch,
                -0.1  // slight Z offset to ensure clean bottom cut
            ])
            cylinder(
                h = board_thick + 0.2,
                d = hole_dia,
                $fn = 12   // low poly cylinder — fine at this scale, faster preview
            );
        }
    }

    // Corner screw holes with countersink
    if (add_screw_holes) {
        for (pos = screw_positions) {
            // Clearance hole through full thickness
            translate([pos[0], pos[1], -0.1])
                cylinder(d=screw_dia, h=board_thick + 0.2, $fn=20);
            // Countersink recess on top
            translate([pos[0], pos[1], board_thick - countersink_depth])
                cylinder(d1=screw_dia, d2=countersink_dia, h=countersink_depth + 0.1, $fn=20);
        }
    }
}

// ============================================
// Print info to console
echo(str("Grid: ", cols, " x ", rows, " = ", cols*rows, " holes"));
