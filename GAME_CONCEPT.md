# Current game concept

## Current direction approved on 10 November 2026

Practice request: small free skatepark-inspired driving area to the left of the stealing lobby. Draft prepared in fresh_prototype/Practice*.luau and PRACTICE_YARD.md. Left interpreted as negative Z when facing +X from van depot toward garages. Flat loop/slalom/braking area with free loaner and return control; no progression/life costs. Studio MCP returned zero instances; NOT installed, connected, or playtested. Check integration checklist and current partial plaza changes before installing. Do not describe draft as completed live work.

Racing becomes the main activity, with stolen vans used as race vehicles. The user accepted five race lives per individual van instead of consuming a van after every race. The loop is steal, secure a van, choose a race, succeed to earn rewards/unlock tracks, retry after failure, and steal replacements when needed.

- Each van begins with five lives. A failed challenge costs one life; five total failures remove that individual van. Wins keep the van and do not reset accumulated failures. Discoveries remain recorded when a van is lost.
- Lives follow the van's unique ID across tracks, switching vehicles, and rejoining; they must be saved. Duplicate vans have separate life counts.
- Successful completion unlocks the next race. The user's longer-term idea is a lobby of ten sequential race portals; start with two playable tracks to validate the loop.
- Practice has no life loss and no progression rewards. Show remaining lives before entry and warn at one life.
- A minor collision or simply placing second does not automatically count as failure. Exact timer/recovery limits and completion requirements still need design. Disconnect/abandon handling remains to be specified; do not assume every disconnect is a loss or enable free reset exploits.
- Currency rewards, track themes, life repair/replenishment, and the future role of passive garage income remain undecided. Do not silently remove implemented garage features.
- This is an approved design direction, not implemented racing functionality. No racing code, portals, or life migration has been built yet.

The prior arrival-plaza rebuild remains incomplete: some scripts were edited, but the world rebuild was blocked when automatic approval review failed with a 403 insufficient-balance service error. It was not tested or delivered. Reconcile the live place and those partial changes before resuming implementation. The design discussion supersedes finishing the plaza automatically.

## Fresh start requested on 7 November 2026

The user has retired the first Studio prototype and wants to rebuild from a blank place after revising the game loop. Current phase: design discussion. Ask for the user's proposed changes and work through them before implementation. Do not continue the old prototype fixes, apply its draft installers, or treat its architecture as a foundation for the new game.

All design and implementation notes below, along with prior roadmaps, reports and code, are historical context. Previous mechanics are candidates for discussion, not binding requirements for the new design. Record newly agreed decisions above this historical material. No new Studio place has been created yet. The old place and files have not been deleted; the user asked to start fresh, not to destroy their previous work.

## Confirmed rules for the fresh design

- Five-tier garages implemented 10 November with agreed capacity/prices; see fresh_prototype/GARAGE_TIERS.md. Starter 3–6, Workshop 8–12 ($12k), Warehouse 14–18 ($36k), Showroom 20–24 ($75k), Elite 28–32 ($130k). Separate spaced plots, progressive same-plot buildings, trader Sell/Upgrades tabs, preview and confirmation, and permanent purchased/max labels. Save schema 2 migrates old capacity 2/3 to Starter 3; legacy capacity3 refunds $180 once. Existing vans/arrival/discoveries/cash preserved. Isolated full-tier purchases and save/rejoin passed; normal store restored. Driving bounds enlarged for new district. Manual higher-tier parking/mobile/multiplayer test still needed.

- Garage progression design confirmed 10 November: FIVE tiers TOTAL including the starter (Tier 1), hence four building upgrades. Separate player garages with clear gaps. Starter has 3 usable slots, individually expandable to 6; reaching 6 is required before buying the next garage tier. Later tiers provide larger space, improved appearance and more capacity. Tier 2–5 included/max slot counts, prices and visual themes are not yet decided. Same-plot rebuilding, upgrade previews and immediately usable included slots are assistant recommendations, not separately confirmed specifications. This design is not implemented yet and supersedes the old two-slot start/three-slot cap for future work. Current running build still uses the old capacity system until migration is implemented.

- 10 November: automatic return sprint requested after delivery. Successful park/exit arms a session-only boost. Crossing the safe line on foot from garage side toward van depot within its width sets WalkSpeed to configurable ReturnSprintSpeed=32 (normal 16). Active HUD badge. Crossing back restores previous speed; starting a valid theft consumes eligibility and clears boost; character removal/death clears it. Capture recovery is separate, boosts do not stack, and eligibility is not saved. Isolated state checks and live crossing/re-entry/UI tests passed. Temporary Studio test harness removed afterward.

- 10 November: user approved duplicate vans in earning slots. Each owned van has a unique ID and consumes one slot; same-type vans each generate their normal income. Discoveries remain unique per type. Arrival bay is only for capacity overflow, not duplicate type. Removed same-type rejection from slot allocation and save validation; duplicate slot/ID rejection retained. Tests in isolated QA store passed: two Rusty earn $4/s with one discovery; third slot promotes same-type arrival to $6/s; selling one pays once/removes only its ID; rejoin restores remaining duplicates and upgrade. Normal store restored; no user save overwritten. Supersedes historical no-duplicate-earning rule.

- 10 November continuation: verified Studio retained saving, scenery and easier parking. Added first-ride guidance using shared Tutorial resolver and client target highlight. New profiles with zero discoveries see steal → escape/park → collect → trader, one objective at a time, with Skip. Existing discoveries suppress guide on rejoin. Server signals successful positive cash collection via CollectedGarageCash attribute. Resolver checks and live startup/escape-to-parking passed; full guide on phone and complete human playthrough pending. Sources and standalone place regenerated.

- Saving acceptance completed after permissions became available: actual DataStore round-trip, active-lock exclusion, upgrades/arrival restoration, sale removal with discovery retention, production transaction checkpoint, shutdown/rejoin, and exclusion of an unfinished theft passed. Full fixture gameplay used isolated RideProfiles_QA_20261109_418fb72d; normal Studio store selection restored afterward, normal profile uncontaminated, latest console clear. Studio left in Edit mode. No live-store test or public publishing. This supersedes pending-permission notes below. See SAVING_STATUS.md.

- Saving follow-up: user confirmed access enabled, but after reconnect exact scope probes still reported DataStore read and update NOT granted. Directed them to Assistant settings > Autorisations MCP > Save & load data. Real storage tests not run; do not bypass permission failures through Play. Installed code refuses gameplay on failed profile load. See SAVING_STATUS.md for next steps.

- Saving implementation installed after user approval: ProfileStore module, atomic UpdateAsync records, per-session lock, retry/validation, autosave, post-transaction checkpoints, leave/shutdown save, and automatic restoration of vans/slots/arrival/discoveries/upgrades/cash/bank. Studio and live stores are separate. Mock storage tests and integrated module load passed. Real storage tests remain pending: MCP GetAsync probe returned Access forbidden; user asked about enabling Studio API access and was given instructions, then asked to confirm API access plus MCP read/update permissions. Do not start Play to bypass this denial. See fresh_prototype/SAVING_STATUS.md. Older session-only descriptions below are historical.

- Follow-up parking feedback: assigned garage was hard to find and parking was too precise. Enlarged earning and arrival pads to 17 by 11 studs (previously 13 by 9), widened visual stripes, increased alignment tolerance to 30 degrees, shortened green hold to 0.3 seconds, retained near-stop requirement (1.2 studs/s). Check now uses a forgiving center zone rather than rotated full-body containment. Added personal garage billboard, on-screen direction/distance card, route beacon, and turn-around hint. Play startup and geometry checks passed; user should judge maneuvering comfort next.

- Parking update on 9 November: crossing the escape line ends the chase but keeps the player driving. An assigned empty earning slot (or arrival bay for duplicates/full capacity) glows amber. Whole van must fit inside, align within 15 degrees of the bay axis (forward or reverse), and remain below 1 stud/s for 0.65 seconds. Bay turns green; E or Exit Van completes parking and exits beside the van. No discovery claim action: discovery and earning ownership register automatically on this validated exit. Leaving alignment revokes readiness. Vehicle controller now permits travel to garages. Tests passed for readiness/revocation, rejected early exits, E exit and camera restoration, automatic discovery, duplicate arrival parking/no extra income. A temporary server-only positioning harness was removed after testing; manual end-to-end garage maneuver still needs user feedback.

- Discoveries register automatically when a previously undiscovered van type reaches the garage safely. The player does not manually record, claim or confirm a discovery. The collection counter updates automatically. This clarifies the existing discovery rule; it does not add another player action.

## Fresh prototype implementation on 7 November 2026

Driving feel enhanced on 9 November: shared Driving module in ReplicatedStorage.RideNetwork, Motion server event, client visual prediction with correction, progressive acceleration/coast/brake/reverse, speed-sensitive unrestricted heading steering, handbrake, wheel animation, brake lights, body lean, chase camera and speedometer. Server retains ownership/capture/economy authority. Tested numerical dynamics and clean-session escape/discovery/camera cleanup. No persistent saving or full terrain vehicle physics added. Original scripts backed up in fresh_prototype/driving_backup_2026-11-09.json; current scripts and standalone place synced locally.

The user authorized building the first fresh prototype. The blank Place1 was verified through the official Studio MCP; original game scripts were absent. New implementation lives in `fresh_prototype/` and in the open Studio place under `ServerScriptService.RidePrototype`, `StartRide`, `StarterPlayerScripts.RideClient`, `ReplicatedStorage.RideNetwork`, and `Workspace.RidePrototype`.

The selected initial scope uses the discussed van loop: three original van types, stationary guards activated by theft, simple road and green safe boundary, automatic discoveries, keep/sell economy, two earning slots plus an arrival bay, NPC trader, acceleration and capacity upgrades. These are prototype choices for testing, not final balancing. Progress is session-only. The previous prototype and its patch installers remain retired; do not apply them to this new game.

Read `fresh_prototype/README.md` and the test result files for current state and limits. Source files and a standalone `.rbxlx` are saved locally. Do not claim multiplayer stress tests, device testing, persistent saving or public publishing are complete.

## Historical design and prototype notes

### Visual update on 9 November 2026

The user requested borders and a more attractive map. Applied a separate Scenery module to the fresh prototype: solid perimeter walls and fence panels, grass ground and hills, sidewalks, trees, lamps, depot entrance arch, colored garage trims and canopies, parking stripes and numbering, cash displays and trader awnings. Hidden the obsolete default spawn and baseplate checker texture. World.Build applies scenery both to existing and regenerated worlds. Verified in Play: all three vehicle paths unobstructed, four-direction boundary collision, no new script errors. Existing missing avatar asset warning persists. Inspected overhead, garage and in-game views. Studio left in Edit mode. Current sources and standalone rbxlx synchronized locally; no publishing performed.

## Agreed core loop

Approach a van, trigger the theft, escape the reacting guard, bring the van to the garage, keep it for passive income or sell it to the NPC trader, upgrade, and attempt a better theft.

- Stealing provides the active challenge.
- Passive income, collection growth, and upgrades provide incremental progression.
- Harder areas can introduce guards, alarms, and longer escape routes.
- Base slots and getaway performance are upgrade candidates. Unlocking-speed upgrades are superseded by the latest guard design below.

## Theme under consideration

Vans are the current candidate, not a final decision. Players could drive a stolen van back to their garage. The thumbnail concept is a normal silver van earning $1/second progressing to a gold van earning $9,999/second; values are illustrative, not implemented or balanced.

The user wants to preserve the core loop while evaluating whether vans or another collectible object makes the best theme. Do not turn this into a delivery simulator. The user is now building a prototype in Qoder.

## Refined design document

See `Steal_a_Ride_Game_Loop.txt` for the design document requested on 2 November 2026. It includes keep-or-sell income choices, collection milestones, the temporary arrival bay, recoverable failure, and NPC lots for solo play. These refinements are recommendations, not playtested results. Vans remain the prototype theme; broader vehicles are optional later.

The formatted `Steal_a_Ride_Game_Loop.docx` includes the loop and rules as tables. `build_game_doc.py` generates both DOCX and the synchronized TXT companion. Visual rendering is blocked by the missing LibreOffice executable; do not claim visually verified pagination.

## Latest requested refinements

- Simple roads, particularly a short, wide, obvious first drive.
- The garage boundary immediately ends guard pursuit; only a van physically secured there counts as a discovery.
- Each collection has eight distinct discoveries. Selling never removes discoveries; 8/8 opens the next collection lot. All current-set types must be available before its completion gate.
- NPC trader replaces discarding and the automatic theft cash bonus. Keep secured vans for passive income or sell for cash. Show sale value, lost income and confirmation.
- Full garages use one non-earning arrival bay, not permanent storage. Sell an existing or incoming van and resolve the bay before another theft. Save the bay across reconnects.
- Guard capture uses a short ragdoll ejection, resets pursuit and gives temporary non-stacking on-foot speed and capture protection. Effects end when a new theft starts or a vehicle is entered. Existing progress stays safe.
- Prototype first tests three van types and an explicit 3/3 test collection, then expands to the actual eight-type set. No unreachable 8/8 checklist in a three-type build.
- No escape countdown in the initial version. Player-to-player trading remains deferred; NPC trading is included.

## Latest guard decision saved at the user request

- Guards remain stationary until the player triggers a theft. Players approach freely; no waiting for a patrol to turn or sneaking through a patrol route.
- Press Steal, play a brief entry animation, then trigger the alarm and guard reaction. Give the player control and a short readable head start before pursuit.
- The escape provides the challenge. The first theft stays forgiving; later guard reaction times and van acceleration can vary difficulty without complicated roads.
- Entering the garage still ends pursuit. Capture still uses the agreed ragdoll ejection and temporary on-foot sprint recovery.
- Replace the previous unlocking-speed upgrade with a getaway upgrade such as acceleration. This is the accompanying design recommendation; exact effects and timing remain untested.
- The user's motivation is reducing idle waiting and getting players into the action quickly. Do not claim patrol waiting has been proven to cause churn; validate through playtesting.

On 4 November 2026, the DOCX, TXT and builder were updated to match this decision. The getaway upgrade is described as persistent acceleration improvement applied to stolen vans, retaining their normal top speeds and handling differences. Exact strength and cost remain untested. Content and table structure passed checks; visual rendering still fails because LibreOffice is unavailable.

## Implementation handoff on 5 November 2026

The user will continue coding in Qoder and wants task sequencing and a way to assess progress. See QODER_BUILD_ROADMAP.md for ordered tasks and acceptance checks. The last live inspection read GameServer through Studio's script editor; no live playtest was completed by Codex. guard_flashlight_update.luau was prepared but NOT applied or tested because UI interaction was repeatedly interrupted. Do not claim the guard or flashlight has been updated. Inspect current Studio code before applying any draft patch; Qoder may have made newer changes.

### Subsequent live review on 5 November

See PROTOTYPE_REVIEW_2026-11-05.md. The newer place has a flashlight and animated guard from intervening work, not from Codex applying its draft. Codex observed spawn, the sweeping beam and a capture outcome after E, read the live GameServer, and stopped Play. A full successful escape was not tested. New source implements pre-theft flashlight detection, contrary to the agreed rule. Missing recovery immunity, uncanceled sprint timers, collection-triggered teleport/restock, flat securedOnce income and shared player state remain. Do not apply the old guard patch blindly to this newer code. Restore theft-only activation while preserving visual improvements.
