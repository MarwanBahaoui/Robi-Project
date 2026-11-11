# Player saving implementation

Installed in Studio; real DataStore and Studio stop/rejoin checks passed after permissions were enabled.

## Stored data

Duplicate-type ownership is supported as of 10 November: unique IDs and distinct slots are required, but van types may repeat. Two earning Rusty vans and one Rusty arrival were restored in an isolated QA store; promotion, per-van income, exact-ID sale and subsequent rejoin all passed. Duplicate slot and duplicate ID validation remain active. Existing records remain compatible with schema 1; no destructive migration or player-data reset was required.

One record per UserId contains cash, uncollected income including its fractional remainder, owned van IDs/types/earning slots, discovered types, garage capacity, acceleration upgrade, and the arrival-bay vehicle (slot zero). Garage assignment is session-specific, so owned vans are recreated in the player's currently assigned garage. Active theft, driving position, temporary sprint/protection and parking-in-progress are not stored as ownership. No offline earnings are added.

Studio uses RideProfiles_Studio_v1. Published servers use RideProfiles_Live_v1. Each contains independent progress. Local rbxlx files must be associated with a published experience before real DataStores are available.

## Write policy

UpdateAsync atomically loads and claims a profile with an expiring session lock. Every write verifies the same lock owner. Saves are serialized per player, retry up to three times, autosave at 45-second intervals, and checkpoint meaningful transactions after a 10-second minimum interval. PlayerRemoving and BindToClose attempt a final save and release the lock. Shutdown has a bounded wait. Abrupt crashes or sustained Roblox storage outages can still lose changes since the last successful checkpoint; this is not a transactional bank guarantee.

Unknown/corrupt save formats are preserved and rejected, not replaced with defaults. Failed loads prevent gameplay and saving. A profile held by another active server asks the player to retry later. Lost ownership prevents stale writes. No reset-data or wipe control is exposed to clients.

## Verified

- Profile module tests with an in-memory UpdateAsync adapter: new record, full save/load round trip, fractional bank, capacity/acceleration, arrival bay, sold-van removal and retained discoveries.
- A second session cannot take an active lock; an expired lock can be claimed; the old session cannot overwrite it.
- Simulated request failures preserve stored data; failed loads cannot write defaults.
- Unsupported schema, non-finite cash and duplicate earning slots or IDs are rejected without rewriting the record.
- Integrated Game module parses/loads in Edit mode without executing a storage request.

## Permission history

The MCP read probe returned `502 ... Access forbidden`. Enable DataStore read and update under Assistant Settings > MCP Permissions > Save & load data. Game Settings > Security > Enable Studio Access to API Services must also be enabled for Studio tests. The user was asked to confirm these settings. No denied request was bypassed by starting Play or using another API. Real DataStore round-trip, reconnect, autosave, shutdown and two-server integration have not been verified.

After the user confirmed settings and Studio reconnected, the read/update probes still failed. Harmless scope-token probes specifically reported both `universe-datastores.objects:read` and `universe-datastores.objects:update` were not granted. The user was directed to Assistant settings > Autorisations MCP, distinct from Serveurs MCP. Current Studio session at the time: a7217231-1bfc-4603-b30a-3c6c6f3ba018. Rediscover the session before further testing.

Permissions subsequently became available. Read and UpdateAsync probes succeeded. The game intentionally prevents play after a failed profile load rather than silently starting a disposable session. There is no fallback that can overwrite saved progress.

## Completed real storage acceptance checks

1. Real ProfileStore round-trip on isolated key `__qa_418fb72d-3d27-4bc7-ae6c-f148819dcee6` in the Studio store passed for balances, fractional bank, upgrades, owned and arrival vans, active-session exclusion, release and reload, sale removal and retained discoveries. Lock released after the test.
2. Game integration used isolated store `RideProfiles_QA_20261109_418fb72d`. A fixture with cash 500, bank 25.5, two earning vans, one arrival van and three discoveries restored as actual garage models.
3. Production trader requests sold Rusty, promoted Sport from arrival, and bought acceleration/capacity upgrades. Cash became 290, two vans remained, all discoveries remained. A transaction checkpoint was read back from actual DataStore.
4. Stop/Play restored cash 290, capacity 3, acceleration 1, both remaining vans and banked income; sold Rusty stayed removed. A later unfinished Rusty theft was excluded from the shutdown save, which released the session lock. Store revisions advanced through checkpoints and shutdown writes.
5. Normal Studio store selection was restored in Game source; QA identifiers are absent from production scripts. The user's normal Studio profile remained empty, uncontaminated by test fixtures, and loaded successfully on a fresh Play. Console had no errors. Studio left in Edit mode.

Long-running outage recovery, real simultaneous multi-server gameplay, and production live-store tests remain unverified. Test records were left isolated with released locks; no live-player store was touched. No public publishing was performed.

Backups before integration: persistence_backup.json. Module: ProfileStore.luau. Tests: test_profiles.luau. No public publishing was performed.
