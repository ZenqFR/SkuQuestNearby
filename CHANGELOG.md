# Changelog

All notable changes to SkuQuestNearby are documented here.

## [0.3.4]

### Fixed
- **Localization audit found a real English/German gap**, checked directly rather than assumed after the user asked to confirm an English version is genuinely available: the activation message printed on login hardcoded the FRENCH menu path ("Quêtes -> Objectifs de quêtes proches") into all three language branches, so an English or German client saw their own sentence with French menu names stitched in (Sku's own root Quest menu is actually "Quests" in both those languages, only "Quêtes" in French). `/sqn`'s own output had no localization at all -- always French regardless of client language. Both now use the same per-language labels the menu itself already displays.

## [0.3.3]

### Fixed
- **Misleading sort order when a quest's real objective can't be resolved.** "Objectifs de quêtes proches" falls back to showing the quest giver's own position when an in-progress quest's real objective can't be located (see 0.3.0) — a real position, but not the actual unfinished objective. Standing near a quest hub (several NPCs at once) made every quest using that fallback look like "the closest thing to do right now" purely because its giver happened to be nearby, even outranking quests with a REAL, resolved, actionable objective distance that was genuinely further away. Fallback-resolved entries now sort behind every entry with a real resolved distance (still shown, never hidden — just no longer able to bury an actionable objective under a merely-nearby giver). The label also now says so explicitly (e.g. "20m, objectif, PNJ donneur, approximatif") so a small distance is never mistaken for "the objective is basically done" when it's really "here's the quest giver, the real objective is still unresolved."

## [0.3.2]

### Fixed
- **Root-caused and fixed Shift+DownArrow reading nothing in "Objectifs de quêtes proches"** (it already worked in "Quêtes à accepter à proximité"). `SkuQuest:GetTTSText`'s parameter, despite being named like a quest ID, is actually used as a **quest log INDEX** (`SelectQuestLogEntry`/`GetQuestLogTitle`, the classic index-based quest-log API, valid range `1..GetNumQuestLogEntries()`) — confirmed by reading its only two real call sites in Sku's own "Aktuelle Quests" code, which build that index from the log's own loop position, never from a real quest ID. This addon builds its list from real quest IDs (e.g. 1489, 6384 — always far outside that tiny index range), so `GetQuestLogTitle` silently returned nil (out of range, no error) and `GetTTSText` returned nothing to read — no crash, no log trace, just silence. Fixed with a new `FindQuestLogIndex(questID)`, resolved fresh on every Shift+DownArrow press (the log's index order can shift between opening the list and reading it), passed into `GetTTSText` instead of the real quest ID. `GetQuestDataStringFromDB` (used by "Quêtes à accepter") is a different, properly ID-keyed lookup and was never affected.

## [0.3.1]

### Changed / diagnostic
- `OnEnter` (both lists) now logs unconditionally — fired + success/failure with returned character count — instead of only on failure, to distinguish "never fires" from "fires and returns nothing" while chasing the bug fixed in 0.3.2.

## [0.3.0]

### Fixed
- **Much broader distance resolution**, addressing "je veux qu'à chaque fois la distance soit affichée": out of a typical 12-quest log, only 2-3 previously ever resolved a distance. Three failure modes fixed:
  1. **Item-collection objectives** are now traced back to their drop sources (`npcDrops`/`objectDrops`/`vendors` on the item's own database entry), keeping the closest.
  2. **Cross-zone search**: creature/object targets are no longer restricted to the player's current zone — every zone with a recorded spawn is searched, kept to the same continent as the player (a cross-continent straight-line distance would be a meaningless number, not just an imprecise one).
  3. **Quest-giver fallback**: an in-progress quest whose real objective still can't be located falls back to showing distance to its own giver instead of no distance at all (the quest doesn't change label — still shown as "objectif", not "à rendre").
- Fixed a `pcall`-swallowed silent failure in both `OnEnter` handlers that could leave Shift+DownArrow silently returning nothing with zero log trace of why.

## [0.2.1]

### Fixed / diagnostic
- Fixed a real logging gap: `OnEnter`'s `pcall` around the description lookup silently swallowed a failure, making it impossible to tell "never fires" from "throws" from the log alone. Now logs on failure for both lists.

## [0.2.0]

### Changed
- **Simplified from three lists down to two**, per direct feedback that the original three-way split ("en cours" / "à rendre" / "à accepter") wasn't behaving correctly and felt over-complicated: "quêtes en cours" and "quêtes à rendre" are now ONE list — "Objectifs de quêtes proches" — sorted purely by distance, with a label suffix ("objectif" / "à rendre") to say which kind each entry is. "Quêtes à accepter à proximité" stays separate (discovering a new quest is conceptually different from progressing one already in the log).
- Flattened the menu structure to match Sku's own "Aktuelle Quests"/"Questdatenbank" depth exactly — quest entries appear directly as children of each top-level entry, no intermediate grouping node.
- Fixed Shift+DownArrow doing nothing for available-to-accept quests — that list was missing an `OnEnter` handler entirely in the first version, and needed a different data source (`GetQuestDataStringFromDB`, not `GetTTSText`) than in-progress quests.
- Added real diagnostics to distance resolution (`ResolveClosestDistance` now returns a reason string on failure), logged per-quest, to make the next round of "why is this quest's distance missing" reports diagnosable from the log instead of guesswork.

## [0.1.0] — first version

### Added
- Initial build: three menu lists (en cours / à rendre / à accepter) injected into Sku's own Quêtes root menu, built on `SkuQuest:GetQuestTargetIds`, `SkuQuest:CreateQuestSubmenu`, `SkuQuest:GetUnsortedAvailableQuestsTable`, and Sku's own bundled `SkuDB` for spawn positions. Same-zone-only distance resolution; item-type objectives deliberately left unresolved (addressed in 0.3.0).
- Self-diagnostic log (`/sqnlog`, `SkuQuestNearbyLog`), toggle from Sku's Features menu, `/sqn` chat summary.
