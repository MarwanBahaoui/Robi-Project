# Steal a Ride fresh prototype

Built from scratch on 7 November 2026. The retired prototype was not used as the implementation base.

## Play

Five-tier garages are now implemented. Start with 3 slots and expand to 6, then purchase Workshop, Warehouse, Showroom and Elite upgrades, ending at 32 slots. Open the trader's Garage upgrades tab for prices, requirements and preview. Empty player plots are labeled Waiting for player. Existing saves migrate without losing vans or progress; previous paid third-slot owners receive a one-time $180 refund. See GARAGE_TIERS.md for all prices and verification details. Old references below to a two-slot start and three-slot maximum are superseded.

Return sprint: after parking and exiting a delivered van, cross the green line toward the van depot to run at 32 studs/second. A RETURN SPRINT badge appears. Crossing back to the garages restores normal speed. The next theft or respawn clears the boost. It is session-only and separate from capture recovery. Boundary/direction, nonstacking, cleanup, original-speed restoration and live crossing/UI checks passed; test setup armed eligibility through a temporary server-only harness that was removed afterward.

Duplicate vans are now allowed in earning slots. Each van takes one slot and earns independently; two Rusty vans earn $4/s total. Only the first of each type adds a discovery. Full capacity sends the next van to the arrival bay; selling one or buying a slot can promote it. Each duplicate retains its own ID for saving and selling. Real storage/rejoin, duplicate income, slot promotion and exact-instance sale passed in an isolated QA store on 10 November.

First-ride guide added 10 November: players loading with no discoveries receive one objective at a time with a highlighted target: steal Rusty, escape/park, collect income, and visit the trader. Skip hides the guide for the session; opening the trader completes it. Players with discoveries already saved do not receive the first-time guide again. State-transition tests passed; Play verified starter highlight and real theft/escape advancing to parking. Cash/trader transitions were checked in the resolver, not replayed as a full new end-to-end onboarding session. No save schema changes were required.

Parking comfort update: bays are now 17 x 11 studs with a forgiving center zone, 30-degree alignment tolerance, and 0.3-second stop confirmation. A direction/distance card, YOUR GARAGE marker and route beacon guide you. Stop with Space, then press E once the bay is green. The older 15-degree and 0.65-second thresholds described in historical notes are superseded.

Parking update: after escaping, drive into the amber bay assigned in your own garage. Center and straighten the van, then brake and hold still. Green means correctly parked: press E or tap Exit Van. Only then is the van secured and discovery recorded automatically. Driving out of the marked position cancels the green state. Full-capacity deliveries use the arrival bay. The chase ends at the green road boundary, so there is no time pressure while parking. Automated geometry and server integration checks passed; final parking positions were supplied by a temporary Studio-only harness, removed afterward. A manual driving approach to all garage layouts remains useful usability testing.

Driving update on 9 November: progressive throttle, coasting, braking before reverse, limited reverse speed, smooth speed-sensitive steering, Space/touch handbrake, animated wheel spokes and front-wheel steering, brake lights, body lean, speedometer and heading-following chase camera with modest speed FOV. A locally predicted visual van responds to input and reconciles against server-authoritative motion snapshots. Input timeout stops unattended acceleration. Keyboard checked; gamepad and phone controls need device playtesting. Driving remains an arcade road controller rather than full suspension/terrain physics. Capture and successful garage arrival restore character camera/FOV and remove the local visual van. Numerical checks passed for braking/reverse, handbrake, direction and 30/120Hz consistency; clean-session real-input escape and automatic discovery passed.

The new prototype is installed in the open Studio place. Press Play. Alternatively, open `Steal_a_Ride_Fresh_Prototype.rbxlx` in Roblox Studio and press Play. The file contains an editor preview of the map; startup replaces that preview with the scripted interactive world.

- Walk to a van and press E or tap its Steal prompt.
- W/S accelerate or reverse; A/D steer. Touch driving buttons appear on touch devices.
- Cross the green line to secure the van in your assigned garage.
- Discoveries are recorded automatically. This test contains three types.
- Collect banked earnings from the green block in your garage.
- Interact with your garage trader to sell a van or buy an upgrade. Sales require a second confirmation.
- Two earning slots are available initially. A third costs $180; an acceleration upgrade costs $90. Values are prototype tuning, not a finalized economy.
- A van goes to the non-earning arrival bay only when all earning slots are full. Resolve it before another theft. Selling any van preserves discovery progress.

## Included

Rusty, Armored and Sport vans; theft-triggered guards; a forgiving starter escape; funny capture and temporary recovery sprint; separate lot and owned vehicles; automatic discoveries; per-player cash and garage records; income based on occupied earning slots; trader confirmation and repeat-request protection; slot and acceleration upgrades; desktop HUD and touch controls; four assigned garage positions.

## Limits

Player saving is implemented for cash, banked income, owned vans, discoveries, upgrades and the secured arrival bay. Real DataStore round-trip and Studio stop/rejoin checks passed; see SAVING_STATUS.md. Studio and published games use separate stores. If loading fails, gameplay stops to protect existing progress rather than silently starting with empty data. There is no offline income, monetization, player trading or eight-van release collection yet. Targets are shared and each permits one active theft at a time. Four garages exist; large-server support is not implemented. The arcade driving controller uses fixed-height movement and bounded roads rather than full vehicle physics. Art, audio and animation are prototype quality. The player is hidden while driving and a chase camera follows the van.

## Validation

Tests use actual game keyboard prompts and driving input, with server-side repositioning between scenarios to shorten test travel. Client-side test code exercises the production trader requests and checks resulting HUD snapshots; this does not replace a human usability test.

Verified in Studio: free approach without guard activation; capture and control recovery; immediate retry restores normal speed; successful escapes with all three vans; automatic 3/3 discovery; arrival bay produces zero income; collecting cash retains vehicles and player position; trader opens through its prompt; cancel leaves ownership unchanged; confirmed sale pays once even if repeated; discoveries survive sales; sale can promote an eligible arrival; income changes accordingly; acceleration purchase and repeat-purchase rejection. See JSON result files for test outcomes. Earlier failed test runs are retained as diagnostics, not counted as passes.

HUD and trader viewport were inspected visually. Touch controls are implemented but have not been tested on a physical phone. Multiplayer ownership is separated in code, but simultaneous multi-client testing remains outstanding. Studio also reported missing avatar asset 81504106, which the prototype does not reference.

The third-slot purchase was observed before the final correction. Automatic promotion on slot purchase was added afterward, but its isolated test could not reach the necessary arrival-bay setup reliably. Repeated automated Sport retries sometimes did not trigger the prompt despite successful input-tool responses; the earlier full fresh-session suite passed all three thefts. Manually test Sport stealing/retrying and slot-purchase promotion before treating them as fully verified. The prototype is ready for iteration, not a production release.

## Files

- Config.luau: tuning and vehicle types.
- World.luau: original map, guard and vehicle geometry generator.
- Game.luau: server gameplay, guard, economy, ownership and purchase validation.
- Client.client.luau: controls, camera, HUD and trader panel.
- Start.server.luau: server entry point.
- prepare.py: produces the portable Studio place and installation payloads.

Do not run installation payloads again on the already-installed place. Use targeted edits against the current source. Public publishing has not been performed.
