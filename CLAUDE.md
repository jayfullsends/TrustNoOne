# Trust No One

A Murder-Mystery-2 / Twisted-Murderer-style hidden-role round game. Roblox
Luau, built with Rojo + VS Code. This is my game #2 — Blade Legends is
finished and shipped, so this is the only game project in flight.

My general working style and teaching preferences live in `~/.claude/CLAUDE.md`.
This file is project detail only.

## Core Loop

Waiting → Intermission → Active → Ending. Secret role assignment with a
per-player reveal, knife + revolver combat (server-authoritative), kill flow
and win conditions, then an end-round stats screen. The loop is built and
playtest-confirmed.

## Knives and Crates

The knife/crate collecting system IS this game's economy — not a separate
project. Knives are the in-game weapons. Crates are the unlock path: players
earn coins in-round, spend them on a crate, it spins, and lands on the knife
they unlock. Skins stay cosmetic-only — no pay-to-win stat traits.

Crates are in-game-coin only. No Robux crates, which keeps this clear of
Roblox's "Paid Random Items" policy.

## Layout

Rojo maps `src/` into the DataModel:

- `src/server/Services/` — ServerScriptService. Data, Game, Combat, Role,
  Stats, Coin, Lootbox, Admin, Tag.
- `src/client/Controllers/` — StarterPlayerScripts. One controller per UI
  system, each owning its own ScreenGui with `:Open()` / `:Close()`.
- `src/client/Cosmetic/` — client-side spin loops (coins, item displays).
- `src/shared/Configs/` — Item, Crate, Rarity, GameRoles, Maps.
- `src/shared/Modules/` — Framework, GameStates, RemoteStorage.

Both Bootstrappers hand off to `Framework`.

## Conventions That Bite Me

- Every controller and service module must end with `return <Module>`, or
  Init/Start silently never fires.
- Services are fetched via `Framework:GetServices`, keyed by `module.Name`.
  Circular pairs (GameService ↔ CombatService) grab each other in `Init`.
- A lifecycle method must never block the lifecycle. `Start` is `task.spawn`ed
  per service because a `while true` loop in one `Start` used to stall every
  service after it.
- Currency lives in `DataService.Currencies` (e.g. `Currencies.Coins`).
  There are no leaderstats in this game.
- Inventory is a dictionary keyed by item name, per category, and the value is
  a metadata table — not a count. `#someDict` always returns 0.
- `ItemConfig` is the item encyclopedia (every item, flat, with a `Category`
  field). Obtainability and drop weights live in `CrateConfig`.
- Change a data shape, update the readers in the same pass.
- Anything resolving `workspace.Map.*` at module load will hang forever once
  maps are cloned at runtime. Pass the folder in instead.

## Hidden-Role Security

Role secrecy is a server concern, never a UI concern. Never send a player's
role to another player's client and hide it in the UI — don't send it at all.
The same goes for live round stats: a spectator seeing Kills > 0 identifies
the murderer, and Shots > 0 identifies the sheriff.

Every admin action re-checks rank on the server. UI presence is never trust.

## Scope

MVP is the round loop, the crate/equip economy, and one map. Trading, codes,
search/sort, item effects, and stat traits are post-launch. Trading and Robux
gacha would also flip Roblox maturity descriptors, which is a second reason
they wait.
