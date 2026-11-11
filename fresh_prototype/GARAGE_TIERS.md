# Five garage tiers

Implemented 10 November 2026. Tier 1 starts with 3 slots, expands to 6. Tier 2 Workshop: 8–12 slots, building $12,000. Tier 3 Warehouse: 14–18, $36,000. Tier 4 Showroom: 20–24, $75,000. Tier 5 Elite: 28–32, $130,000. Each current tier must have all slots unlocked before buying the next building; occupancy is irrelevant.

Slot prices in order: Starter 400/900/1800; Workshop 2400/3200/4000/5000; Warehouse 6500/8000/9500/11000; Showroom 14000/16000/18000/20000; Elite 24000/28000/32000/36000. Full expansion from a fresh starter totals $493,700.

Each player keeps a separate plot, spaced 152 studs apart with capacity reserved for the final footprint. Tier rebuilds preserve owned van IDs and recreate displays in their slots. Eligible arrivals promote automatically. Garage upgrades are refused during a theft. The trader has Sell vans and Garage upgrades tabs, next-building concept preview, prerequisites, prices, confirm step, and persistent purchased/max labels. The preview is a schematic illustration, not an exact architectural rendering.

Save schema 2 adds tier. Schema 1 records migrate atomically to Starter with 3 slots, retaining all vans, arrival, discoveries, bank, cash and acceleration. Legacy capacity 3 receives a one-time $180 refund for the now-free slot. Schema 2 prevents repeated refunds. Max validation supports 32 owned earners plus one arrival, with duplicate types allowed and duplicate slots/IDs rejected.

Verified: every slot and building price, tier prerequisite rejection, insufficient funds, upgrade refusal while driving, max-tier repeat rejection, arrival promotion, all owned models surviving rebuilds, max-tier save/rejoin, migration/refund once, plot gaps, and bay coordinates within driving bounds. QA used RideProfiles_QA_Tiers_20261110; normal store restored. Normal player's legacy data loaded with vans/arrival preserved. No console script errors. Visual checks of Starter upgrade preview and Elite max-state passed.

Still needs user testing: driving through the enlarged district to all plots and parking in deep rows at higher tiers; physical-phone layout; simultaneous player upgrades. Architecture is procedural prototype art. No public publishing performed.
