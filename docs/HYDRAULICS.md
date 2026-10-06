# Irrigation Hydraulics

The calculation engine is in `irrigation/tt-hydraulics.lsp`. It does not read or change CAD entities. The irrigation command layer supplies validated geometry and equipment data.

The release candidate uses US customary inputs: pipe length in feet, flow in US gallons per minute, inside diameter in inches, pressure in psi, and elevation in feet.

Hazen-Williams head loss is `h_f = 4.52 L Q^1.85 / (C^1.85 d^4.87)`, where `h_f` is feet of water, `L` is feet, `Q` is gpm, `C` is the Hazen-Williams coefficient, and `d` is inches. Pressure loss is `h_f / 2.31`. Velocity is `0.4085 Q / d^2` feet per second. Total reported loss is friction pressure plus elevation rise divided by 2.31 plus entered equipment losses.

`TTSIZEPIPE` tests the catalog's available diameters from smallest to largest and returns the first size meeting both velocity and friction limits. `TTIRRIGATIONSIZE` derives the selected pipe's own downstream demand and does not change a pipe until the user answers Yes. An existing manual choice is never silently overwritten.

Smart LINE direction defines network direction: group code 10, the start point, is upstream; group code 11, the end point, is downstream. Equipment at endpoints contributes demand. A 0.01 drawing-unit tolerance connects endpoints. Directed recursion propagates downstream flow and reports loops. Equipment with positive demand and no connected pipe endpoint is reported as disconnected. Multiple incoming edges at one node are reported as an ambiguous merge. Sizing stops for a station with a loop or merged path.

`TTCRITICALPATH` uses a user-selected pipe set. Each segment uses its own downstream flow. The report shows the maximum downstream flow on the selected path and summed segment losses, and transiently highlights the path. Automatic critical-path discovery is not claimed in this release candidate. Available pressure, required terminal pressure, and equipment loss assumptions must be entered or assessed by the designer; TerraTools does not invent them.
