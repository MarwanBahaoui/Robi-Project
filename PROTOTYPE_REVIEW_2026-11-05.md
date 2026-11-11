# Live Studio prototype review

Reviewed 5 November 2026. Place window: Lieu de Lumineer01 : 11042026_1.

## Scope and evidence

Inspected the actual Roblox Studio window, started Play, inspected the spawn and flashlight, pressed E and observed the CAUGHT state, and read the current GameServer through the live script editor accessibility text. Stopped Play afterward. No game code or assets were changed in this review.

Did not complete a successful manually driven escape, verify selling or saving, run a multiplayer session, or test on mobile. Input focus interruptions limited the playtest. Do not treat this as a full gameplay certification or a measured retention test. Source findings below are code inspection, not reproduced gameplay failures unless explicitly identified.

## Assessment

There is visible progress: the rusty van is recognizable, the guard has a readable silhouette and a visible sweeping flashlight, and the nearby Steal prompt gives the player an immediate action. The build is still a one-van mechanics prototype. Complete and correct that small loop before increasing art volume or adding eight vehicles.

## Fix first

1. Restore theft-triggered pursuit. GameServer's patrol branch accumulates flashlight detection and calls startChase even without an active theft. shooPlayer explicitly tells players to wait for the light to pass. This contradicts the agreed free approach. Keep the idle flashlight animation cosmetic. Start the guard reaction only after Steal and allow a readable head start. Acceptance: walk around the lot for 20 seconds without stealing and receive no chase or shove; stealing then starts the reaction and chase.

2. Make recovery protection real. capture advertises six seconds of capture protection but only sets PlatformStand, applies velocity, later teleports the player and sets WalkSpeed to 32 before resetting it to 16. There is no immunity check in the current guard capture/shove logic. Recovery callbacks also are not canceled by a new theft. Track recovery per player and character, preserve original movement settings, prevent repeated knockdowns, and end the boost/protection when another theft starts. Acceptance: capture, recover, retry immediately, and verify an old timer cannot interrupt the new ride; reset the character during recovery and verify cleanup.

3. Keep earned vans in the garage. collect calls returnVanHome and teleports the player to the lot. This is a repeat-test shortcut, not the intended ownership loop. Separate target instances from owned vehicles; collection should transfer banked cash only. Acceptance: collect money, remain at the garage, see the owned van still parked and a separate new target available at the lot.

4. Tie earnings to owned slots. The income loop still pays a flat amount whenever securedOnce is true, including after the one van returns to its lot. Use the actual set of parked earning vehicles. Integrate the trader and arrival bay into that ownership model. Acceptance: non-earning bay vans add zero income; selling an earning van removes exactly its contribution; sale confirmation pays only once and discoveries remain.

5. Fix HUD placement. In the observed Studio play viewport, Roblox's top-left controls cover the first money line. A translation notice also temporarily overlaps the discovery text. Respect the top-bar/safe-area inset, separate status text from balances, and check small viewports. The bottom controls hint is small and low contrast. Remove 'stay out of his flashlight' if adopting theft-only detection.

## Before multiplayer or public testing

- One global run and shared balance/discovery state remain. targetRoot returns the first living player's root rather than the active thief's root. With multiple players, the guard can pursue one character while capture affects run.player. Bind chase/capture to the same owner and separate player state.
- The active server configuration is VanData.Rusty, while the HUD displays Discovery 0/3. Confirm all three types are actually obtainable before representing this as a three-item test; the inspected server flow currently operates a single target and securedOnce discovery flag.
- Check sender ownership, finite numeric driving input, rate limits and server-side proximity validation. Current input clamping alone does not establish these protections.
- The inspected GameServer has no persistence implementation. Check for other save modules before claiming none exists anywhere; verify reconnect behavior before public testing.

## Visual feedback

Keep the simple road and obvious target. The guard and flashlight communicate the theme well enough for a mechanics test. The beam appears as broad bright strips in daylight; later soften it and make sure any visual detection cone agrees with actual gameplay. The rusty van texture is busy and covers most panels; later add clearer window, door and body color separation. Neither needs a full art rebuild before fixing the loop.

## Next focused Qoder task

Inspect the current Studio place and preserve existing changes. First fix theft-only guard activation and capture recovery, using findings 1 and 2 above. Keep the flashlight and idle animations. Do not add patrol waiting or alter the economy in this task. Test free approach, steal reaction, capture, rapid retry, character reset and garage arrival. Record Pass, Fail or Untested for each; save a checkpoint. Address ownership and income in the next task.
