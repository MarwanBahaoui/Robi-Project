# Practice yard draft

Requested 10 November 2026. NOT installed or playtested: Studio MCP returned no connected sessions throughout preparation.

Placement: negative Z, left when facing from the stealing bays toward the garages (+X). Approximately 194 x 174 studs of driving deck, centered at (-35,0,-195). Free practice kiosk near (-90,2.5,-46) in the stealing lobby. It transports the player into a free loaner van and returns them to the kiosk afterward.

Style: teal concrete perimeter, broad painted oval, inner turn markings, cone slalom, orange braking box and benches. Flat drivable surface, because the arcade controller does not support ramps, jumps or suspension. No timer, rewards, discovery changes, owned-van consumption or lives lost. The five-life racing system remains unimplemented elsewhere.

Files: PracticePark.luau builds the yard; Practice.server.luau creates independent per-player loaners and routes input; Practice.client.luau handles camera/UI, reset/exit and keyboard/touch controls; PracticeDriving.luau reuses the existing driving equations with separate practice-area bounds. PracticeYard_DraftSources.rbxmx contains disabled source scripts for review; it is not a playable place or automatic installer.

Before installation:

1. Reconnect and inspect current Studio sources, especially partial plaza edits. Do not blindly apply stale Game/World source.
2. Confirm location does not collide with the user's current scenery. Inspect pedestrian access to the kiosk. The park is connected through a free practice prompt, not an open drive-through road.
3. Create PracticeNetwork with Action and Motion RemoteEvents; install the four scripts at the paths in practice_install_draft.json. These require existing RidePrototype.World and RideNetwork.
4. Add a PracticeDriving check to the main theft handler to prevent practice/normal driving overlap. Consume/pause return sprint when entering practice; verify the main HUD and camera restore cleanly.
5. Add PracticePark.Build to the map bootstrap so the park appears in Edit-generated/portable builds. Update the standalone place only after runtime verification.
6. Test actual entry input, loop driving, slalom, brake/reverse, practice boundary containment, reset, return, character death, disconnect, simultaneous practice players, and phone buttons. Verify player money, inventory, discoveries and saves are unchanged by practice.

The local packaging check verifies XML structure and confirms the practice server has no persistence API calls. It is not a Luau compilation or gameplay test. No live map changes were made.
