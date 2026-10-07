# Irrigation Hydraulics, 0.12.0-rc1

The pure core uses length in feet, flow in US gpm, hydraulic inside diameter in inches, pressure in psi and elevation in feet.

Pressure friction is `p_f = 4.52 L Q^1.85 / (C^1.85 d^4.87)` psi. `TT:HazenWilliamsHeadLossFT` multiplies that value by 2.31 to return feet of head. `TT:FeetHeadToPSI` divides head by 2.31. Do not apply either conversion twice. Velocity is `0.4085 Q / d^2` ft/s. Total pipe pressure loss includes friction, elevation rise/2.31 and explicit inline equipment losses. A drop can reduce net loss.

The deterministic reference case L=100 ft, Q=10 gpm, d=1 in, C=150 gives 3.0155713291 psi, 6.9659697702 ft head and 4.085 ft/s. Tests include pressure/head round trip and elevation signs.

## Graph and pressure

LINE group 10 is upstream and group 11 downstream. One connected POC is required for each analyzed station. Endpoint tolerance defaults to the drawing-unit equivalent of 3.048 mm and can be changed with TTNETWORKTOLERANCE. Every edge carries the aggregate demand downstream of its TO node. Loops, merged incoming paths, disconnected demand, multiple sources, incoming pipe at source and orphan/reversed branches prevent automatic results.

TTIRRIGATIONANALYZE and TTZONEINFO report the graph demand and required source pressure. TTAUTOCRITICALPATH asks for available source pressure and prints edge flow, actual diameter, velocity, node pressure and margin, then highlights the most demanding route. TTCRITICALPATH is a compatibility entry point for the same automatic analysis. TTREVERSEPIPE reverses a selected LINE while retaining metadata.

Zero-flow inline valves/regulators may contribute explicit LOSS_PSI. Controllers and sleeves are not hydraulic demands. Missing inline loss is zero, not an estimated manufacturer value. Required pressure belongs to the equipment record, or PRESSURE_PSI metadata for a drip area. Head demand is currently stored when placed; changing catalog flow does not automatically rewrite existing XData. Review existing placements after equipment edits.

## Pipe classes and sizing

TTPIPECLASSES manages material/class, C factor and nominal:inside size pairs in inches. TTPIPE prompts for class and size. DIAMETER_IN retains nominal size; INSIDE_DIAMETER stores the actual hydraulic diameter. Legacy pipes without actual ID use DIAMETER_IN explicitly as an assumption. Legacy sample class sizes have no manufacturer-certified inside dimensions.

TTSIZEPIPE is a calculation-only recommendation. TTIRRIGATIONSIZE supports Recommend, Single, Selection, Station and Network. Limits default to 5 ft/s velocity and 5 psi friction **per pipe**, not per 100 feet. Only pipes with MANUAL_SIZE=0 are changed. TTPIPEAUTO explicitly changes that setting. No available passing size is reported without inventing one. Highlighting indicates an undersized or failing existing pipe; REGEN clears it.

TTHYDRAULICMETRIC accepts meters, L/s, mm and kPa, converts to the same core, and converts results back. It does not maintain a separate formula implementation.

## Coverage and drip

Coverage uses stored radius/sweep and head rotation. Refresh creates a valid replacement before removing old helpers. Tilted head extrusion is unsupported. Drip-area count is ceiling(area/(row spacing * emitter spacing)); GPM is count * emitter GPH / 60. The first boundary vertex is the inlet connection point. The current area command stores calculated design demand; after geometry/spacing changes, remove its tag and rerun TTDRIPAREA. No automatic hidden recalculation is claimed.

These are design-assistance calculations. They do not establish code compliance, engineered approval, nozzle uniformity, fitting losses not entered, pump behavior or irrigation adequacy.
