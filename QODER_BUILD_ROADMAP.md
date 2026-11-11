# Steal a Ride build roadmap

Updated 5 November 2026

## Where the project stands

The 4 November build report describes a one-van prototype. During a subsequent live Studio inspection, Codex read GameServer through the script editor and confirmed the single global run, shared garage balance, Rusty-only configuration reference, collection-triggered restock and teleport, and income driven by securedOnce. Codex did not complete a live playtest. The report's successful playtest claims belong to Qoder and were not independently reproduced.

This roadmap is based on that last inspected state. Inspect current Studio code before deciding which work is still missing. Do not replace newer Qoder changes using an older snapshot.

The requested guard flashlight patch was prepared as guard_flashlight_update.luau but was NOT applied or tested. It is a draft tied to the previously inspected GameServer; inspect current code before reusing any part of it. A flashlight remains requested work.

The project is at the first mechanics prototype stage. The next goal is a complete, small, playable loop with three vans. Advanced art and eight-van collections come after that loop works.

## Working method

For each task: inspect the relevant code, state the intended change, implement it, test it in Studio, fix failures, and report evidence. Work on one numbered task at a time. Keep existing working behavior and the agreed design.

Track tasks as Not started, In progress, Blocked, or Verified. Code written is not the same as Verified. Record the test performed, actual result, remaining issues, and saved checkpoint. If a tool cannot run a test, say Untested and give the user a precise manual test.

The user should play each feature themselves before accepting it. A few successful scripted tests do not establish that driving or capture feels good.

## Stage 1 Protect the work

### Task 1 Save and establish a recoverable checkpoint
Inspect whether the place has already been saved. Save a local place copy in Edit mode to a user-visible project location. Export or sync the current scripts into the project and establish version history. Use one clearly documented source for script edits so file sync and MCP edits do not overwrite each other. Do not publish publicly as part of this task.

Done when: Qoder reports the exact saved place path, confirms the file exists, identifies the script files and checkpoint, and describes how to recover that version. Preserve the open place until a valid saved copy is confirmed.

## Stage 2 Make one theft feel right

### Task 2 Finish the guard and first drive
Use the existing simple arcade controller initially. Keep the first road short, wide and readable. The guard stays stationary until Steal is pressed; give vehicle control and a readable head start before pursuit. Add the requested handheld flashlight with a working light. Capture gives a brief comic knockback followed by control recovery and the temporary sprint/protection period. End recovery effects when the next theft begins. Crossing the actual garage safe zone must win over capture on the same update.

Done when: test approach without stealing, idle after stealing to get caught, drive home successfully, and retry immediately after recovery. Verify no lingering sprint, repeat knockdown or late callback changes the next attempt. Check death/reset cleanup. The player can see the flashlight and understands the chase. Existing money and discoveries survive capture. Test basic steering on touch controls as well as keyboard.

Do not assume the draft flashlight patch already satisfies these tests. Keep the guard work small; a full animation or physics rebuild is unnecessary for this milestone.

## Stage 3 Make collection real

### Task 3 Separate ownership from target spawning
Create independent lot targets and owned garage vehicles. Track each player's run, cash, garage slots, discoveries, upgrades and arrival bay separately. Keep van definitions such as type, income, sale price and handling separate from each owned vehicle's unique identity. Collecting income must not remove a parked van or teleport the player.

Done when: secure a van, leave it displayed in the garage, and steal a fresh target. Collect money without moving the player or the owned van. In a two-player Studio test, confirm one player's actions cannot spend or collect the other's money or control the other's active van. Verify departure/reset releases the appropriate run.

### Task 4 Implement keep or sell
Start with two earning slots and one non-earning arrival bay. Income is the sum of parked earning vehicles. Add the NPC trader with a displayed sale price, income-loss information and confirmation. Cancellation changes nothing; confirmation removes exactly one owned vehicle and pays exactly once. Sales preserve discoveries. Duplicates provide no additional discovery or second earning copy of that type.

Done when: fill both slots, secure another van into the bay, and choose whether to sell a parked van or the arrival. Resolve the bay before another theft. Test cancel, repeated confirm, duplicate sales and selling the last earning van. Selling immediately removes that van's income contribution. No automatic theft cash bonus remains.

### Task 5 Complete the three-van prototype
Add Rusty, Armored and Sport with distinct handling or guard reaction tradeoffs. Show a labeled 3/3 test collection. Add one persistent getaway-acceleration upgrade and capacity expansion from two earning slots to three. Upgrades must be affordable through the existing play loop, with no compulsory idle wait.

Done when: discover all three, sell one and retain 3/3, retry a duplicate without increasing progress, purchase each upgrade once and verify its effect. Invalid or unaffordable purchases fail without changing balances. Money and ownership changes are checked on the server. Qoder must report measured timings and prices as test results, not assumed balance targets.

## Stage 4 Preserve player progress

### Task 6 Save progress before public testing
Persist money, uncollected income, owned vans, earning-slot placement, discoveries, capacity, acceleration upgrades and any secured van in the arrival bay. Clear unfinished thefts on leaving; never count an unsecured van as owned. Handle save/load errors without overwriting existing data with defaults. Use isolated test data during development.

Done when: rejoin after earning, selling, upgrading and leaving a full arrival bay. Confirm each saved value restores correctly and sold vans stay sold. Test a save/load failure and repeated sale/purchase requests. Progress must remain separate for two accounts. Never test destructive reset behavior on real player data.

## Stage 5 Find out whether people enjoy it

### Task 7 Run a small playtest and fix the biggest friction
Invite 5-10 testers. Observe first theft completion, capture recovery, keep/sell understanding, upgrades and whether they voluntarily try another theft. Record confusion, repeated failures and time spent waiting. Test on a phone, not only a desktop viewport. Decide what to improve from observations rather than declaring success because the console has no errors.

Done when: the core actions work reliably, players understand their next goal, and the most common frustrations have been addressed. These tests diagnose usability and initial enjoyment; they do not prove commercial success.

## Stage 6 Expand a proven loop

### Task 8 Add the first eight-van collection and focused polish
Replace the test set with a complete eight-type collection. All eight must be attainable before the next-lot unlock. Add one consistent visual style, readable UI, simple sound feedback and vehicle variety. Preserve the stationary-until-theft guard rule and keep the first road simple. Expand one area at a time.

Done when: a tester completes 8/8 without an unreachable or excessively rare missing type, unlocks the next lot, and retains all discoveries through sales and reconnects. The new content does not break earlier acceptance tests.

Keep player raids, player-to-player trading, combat, rebirths and monetization outside this roadmap until the core loop is validated and the user chooses to add them.

## First prompt to give Qoder

Read this roadmap and GAME_CONCEPT.md. Inspect my current Studio place and identify which items are already implemented. Complete Task 1 only: create a verified local save and recoverable script checkpoint. Preserve all existing gameplay. Do not start the later stages or publish publicly. Report the saved paths, what you verified, and any blocker. Do not mark a task done based only on writing code.

## Prompt for subsequent tasks

Complete Task [number] from QODER_BUILD_ROADMAP.md. Inspect the current code first and preserve working features. Implement only this task and its necessary dependencies. Run its acceptance checks, fix failures and save a checkpoint. Report each check as Pass, Fail or Untested with evidence, plus anything I should test manually in Studio.
