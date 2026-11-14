# 02 — Normative Gameplay and Combat Rules

**This document takes precedence over descriptive move flavor in other files.** Values are initial balancing targets and may be tuned using Resource files. At 60 simulation ticks/sec, one frame = 16.667 ms. Do not base frame timings on animation playback FPS.

## 1. Arena and coordinates

Side-on 2D. World x increases right, y increases downward. Ground baseline `y=300` in a nominal 640x360 combat viewport; fighter x constrained to `[52,588]` with configurable per-stage walls. Stage collision floor is fixed; fighters cannot move past each other except via eligible cross-up movements, after which facing updates. Both fighters and attacks are mirrored by facing sign (`+1` facing right; `-1` facing left). A fighter's **forward** means their current facing, not global right. No ring-outs or stage hazards in MVP.

## 2. Tick and update order

One authoritative combat tick in `MatchSimulation`:
1. Read one `InputFrame` per fighter, including buffered inputs from keyboard/gamepad/touch/CPU.
2. Resolve direction-relative actions using facing at tick start.
3. Advance fighter state, cooldowns, physics and animation-time counters.
4. Spawn/update hitboxes/projectiles based on frame-accurate attack definitions.
5. Detect collision pairs; collect valid contact candidates.
6. Resolve throws, blocks, hits, armours/invulnerability; deduct HP/meter; apply stun/knockback/hitstop.
7. Clamp stage positions, detect KO/timeouts and emit events for UI/audio.
8. Cache snapshot for optional replay/debug.

Make order deterministic for local gameplay. Floating point drift is acceptable for offline MVP; deterministic netcode is not a requirement.

## 3. Action button mapping and priority

Buttons L (light), H (heavy), S (special), B (block); directions Up, Down, Left, Right. Inputs sampled as held/just_pressed. Input definitions must support simultaneous pressed within a **3-frame chord window** on touch. Priority: (1) H+S super if meter >=100 and legal; (2) L+H throw if in range; (3) directional + S special if legal; (4) S neutral special; (5) H normal; (6) L normal; (7) B guard when no attack triggers. To avoid accidental attacks when guarding, B + an attack button is ignored by default except deliberately mapped taunt or future mechanic. An invalid super chord does NOT spend meter; default to heavy attack on H+S when insufficient meter (configurable). Guard held cannot cancel an attack except through explicitly allowed cancel windows. Up jump; Down crouch; horizontal walk. Resolve opposite horizontal inputs to neutral. Diagonal U+F jumps forward, D+F crouches.

Simplified input set: `L` standing light, `H` standing heavy, `D+L` crouching light, `D+H` sweep, `U+L/H` aerial attacks, `F+L/H` optional directional normals, `S` special_1, `F+S` special_2, `D+S` optional utility (not all fighters required for MVP), `H+S` super, `L+H` throw, `B` high guard, `D+B` low guard. A taunt can later be bound to `D,D+B` (out of MVP).

Input buffering initial 6 frames. Consumption: one held attack should not retrigger until release unless move definition permits auto-repeat. Controller remap and keyboard remap in settings are stretch goals; configurable defaults are mandatory.

## 4. Shared fighter states

`IDLE`, `WALK`, `CROUCH`, `JUMP_START`, `AIRBORNE`, `LAND`, `ATTACK`, `SPECIAL`, `SUPER`, `BLOCK`, `HITSTUN`, `BLOCKSTUN`, `KNOCKDOWN`, `GETUP`, `THROWN`, `KO`, `VICTORY`. State machine must explicitly define legal exits. During HITSTUN/BLOCKSTUN/KNOCKDOWN/THROWN/KO no offensive action, with exceptions only when attack configuration explicitly allows it. A fighter in KO has no active hitboxes. Pausing freezes simulation timers and physics.

## 5. Stats and movement

| Fighter | Max HP | Speed rating | Power | Range | Defense |
|--|--:|--:|--:|--:|--:|
| Ranjan | 1000 | 5 | 3 | 3 | 3 |
| Malinga | 900 | 4 | 3 | 5 | 2 |
| Sri Vikrama Rajasinha | 1200 | 2 | 5 | 3 | 5 |
| Rajangane | 950 | 4 | 2 | 4 | 3 |
| Chamara | 900 | 5 | 4 | 2 | 2 |

Speed/power/etc are **presentation-only 1–5 ratings**, NOT direct damage multipliers. Actual movement in pixel/s configured per fighter; Ranjan 175, Malinga 165, King 120, Rajangane 155, Chamara 180. Jump initial upward velocity around 340 px/s, gravity ~900 px/s²; tune for stage scale. Weight/defense need not introduce hidden damage reductions in v1; use frame properties, HP and hitboxes.

## 6. Standard frame-data starting values

| Move | Startup | Active | Recovery | Damage | On hit |
|--|--:|--:|--:|--:|--|
| Standing light | 5 | 3 | 9 | 40 | + hitstun 12 |
| Standing heavy | 12 | 4 | 18 | 100 | hitstun 17 |
| Crouching light | 6 | 3 | 10 | 35 | hitstun 11 |
| Sweep | 10 | 4 | 19 | 75 | knockdown |
| Air light | 6 | 4 | landing-recovery 5 | 35 | hitstun 11 |
| Air heavy | 10 | 5 | landing-recovery 9 | 80 | hitstun 16 |
| Throw | 7 | 2 | 20 | 110 | knockdown |

Frame timings count startup, active, recovery sequentially; attack lockout lasts sum unless a cancel window is specified. `hitstun` is counted **after hitstop**. All hits register once per attack instance per victim unless the move explicitly lists multiple strike IDs. Hitstop baseline 4 frames light, 6 heavy, 9 super; applies to relevant fighter animations but **global match timer should not tick during hitstop**. All initial attacks are non-lethal through block chip (blocked chip never KOs). Animation frame rate may be 8–15 visual FPS despite 60-tick simulation.

## 7. Attacks and collisions

Hitboxes and hurtboxes are independent `Area2D`/`CollisionShape2D` groups or an equivalent explicit frame-driven geometric model. Only active attack frames deal damage. Distinguish `hit_level`: high, mid, low, overhead, throw, unblockable (unblockable not in initial roster). High/overhead must be guarded standing; low requires crouch guard; mid can be guarded either stance. Airborne attacks may be overhead only when defined. Throw ignores basic guard if opponent grounded/in throw range, but misses airborne/jump-immune targets. Projectiles have lifespan and destruction at wall/hit; per-attacker max active projectile count 2, except super. Armour absorbs **one eligible non-throw hit** for the King's charge, then expires; armour reduces stagger but still incurs damage unless explicit damage modifier is set.

## 8. Defense, hit and counters

Block only while grounded and in legal neutral/guard state (air block deferred). Blockstun 8 for lights, 13 for heavies, move-defined for specials. Chip on blocked specials: `max(1, floor(damage * 0.1))` but capped to leave >=1 HP. Normal attacks have zero chip. Light normals can cancel into nominated specials on hit/block, not whiff; no default heavy-to-light cancels. Guard break, parry and air recovery deferred. Knockdown: 35 ticks default, getup 15, invulnerable during first 10 getup ticks (tunable). Avoid unsafe input queuing while stunned.

## 9. Meter and super

Meter 0–100 integer. On clean normal hit attacker gains 8 light, 12 heavy; defender gains 4 on damage; blocked normal attacker gains 3; specials gain attacker 10 on hit, defender 4. No meter gain on whiff, including missed supers. Super costs all 100 on valid activation, independent of hit/miss. Meter persists between rounds of the same match? **Decision:** resets to 0 each round for simple casual balancing, but training can force full meter. Meter cannot exceed 100. A super cinematic uses brief zoom/flash and hitstop, max 2.0 sec animation in MVP (no mandatory unskippable sequences).

## 10. Combos and safeguards

Create move-specific cancel tables as data: e.g. `light -> light -> heavy` only if `combo_route` allows, with a 6-tick buffer and hit confirm. Cap 8 consecutive registered combo hits and introduce damage scaling `max(0.45, 1 - 0.08*(hit_index-1))` for combo hits 2 onward. Throw cannot be combo-cancelled by default. Infinite loops must be prevented with recovery and minimum gravity/hitstun. Reset combo after 20 ticks without hit, when victim recovers, or round ends.

## 11. Round state machine

`PRE_ROUND` (1.5s) -> `ACTIVE` (99 sec) -> `ROUND_OVER` (2s) -> next round or `MATCH_OVER`. Best of 3 means first to 2 **won rounds**; draws award neither side. If both HP <=0 same resolution tick -> draw. Timer timeout compares remaining HP / max HP, with epsilon 0.0001. If exactly tied -> draw. After 3 consecutive draws, enable sudden-death first valid hit, without timer (a player could still stall; allow user quit). Round win signals play win animation; round reset restores positions/HP/meter. Pause does not tick timer. Invalid state transitions log warnings in dev only.

## 12. AI rules

Finite-state/utility AI, same input interface as human. `APPROACH`, `RETREAT`, `GUARD`, `PUNISH`, `JUMP`, `ATTACK`, `SPECIAL`, `RECOVER`. Difficulty modifies decision interval/reaction delay, approach aggression, reaction noise and combo frequency, **not damage/HP cheats**. Easy reaction 24–35 frames; Normal 14–23; Hard 8–14; randomize via seeded RNG for reproducible tests. AI cannot inspect human future input; it may read publicly observable distance/current fighter state. AI cannot input illegal moves.

## 13. Debug and metrics

Dev overlay: current states, HP/meter, current input action, attack instance, active-frame counter, hitbox bounds, guard direction, FPS and collisions. Provide deterministic dummy replay test scenarios; file-backed match replays optional. Log move IDs, hit result and state transitions in dev build, not in release telemetry.
