# 08 — Implementation Backlog, Milestones and Test Plan

## Phase 0 / Foundation (P0)

`P0-01` Create Godot 4.7.2 project Compatibility renderer, fixed 60 Hz and 640x360; `P0-02` `project.godot` main scene + README instructions; `P0-03` Git ignore, placeholder art/audio resources; `P0-04` headless launch/import parse smoke checks; `P0-05` main menu Start Fight/Quit.

**Acceptance:** Launch in editor, Windows export project configured, menu opens with no missing resource errors.

## Phase 1 / Windows vertical slice (VS-01, must-have)

| ID | Task | Acceptance |
|--|--|--|
| VS-01 | 2 colour-coded placeholders, stage floor | Start match and both appear, facing correctly |
| VS-02 | Keyboard P1/P2 input adapter | Move/jump/crouch; two independent players |
| VS-03 | State machine | Illegal input during hit/KO ignored |
| VS-04 | L/H normals and attack definitions | Start/active/recovery frames respected |
| VS-05 | Hit/hurt resolution | Damage once per strike, only in active frames |
| VS-06 | Guard and hit levels | Mid block, low guard, throw exceptions |
| VS-07 | HP and HUD | Visible HP, timer, two player names |
| VS-08 | KO and rounds | Correct winner, 99-sec timer, first to 2 |
| VS-09 | Audio/visual placeholder events | No missing audio asset failure |
| VS-10 | Windows export and instructions | Local `.exe` launches without Godot editor, if engine/templates available |

**Exit gate:** Two real humans can play best-of-three on Windows offline, round restart reliable, no repeated hit per attack instance.

## Phase 2 / vertical slice complete (VS-02)

`VS2-01` Three basic hit levels + throws; `VS2-02` meter and H+S super; `VS2-03` special/projectile support, including high/low; `VS2-04` simple seeded CPU AI; `VS2-05` Ranjan and Malinga Resource-backed placeholder movesets; `VS2-06` win/lose and character select (2 choices); `VS2-07` Android touch overlay and multi-touch; `VS2-08` APK debug export; `VS2-09` testing on real Android; `VS2-10` performance overlay and balance tuning.

**Exit gate:** Ranjan vs CPU Malinga playable on Windows and Android from menu to match results. Minimal 2 specials and super for each, represented by placeholders if art pending.

## Phase 3 / roster and UX (MVP content)

`MVP-01` Finish fighters Rajangane, King, Chamara; `MVP-02` three stages; `MVP-03` Arcade four-opponent ladder; `MVP-04` Quick Fight/Versus/Training; `MVP-05` full menus and results; `MVP-06` voice event registry and placeholders; `MVP-07` original audio MP3 integration after supplied; `MVP-08` Sinhala/English; `MVP-09` clean/beep/full settings; `MVP-10` controllers; `MVP-11` progress settings persistence; `MVP-12` pass game balance and source/rights tagging; `MVP-13` caricature final art and voice polish.

**Exit gate:** Five fighters distinct, 3 stages, all core modes, full 20-match QA, platform performance measurements.

## Phase 4 / commercial release (release blocker)

`REL-01` Ad/billing provider Android integration; `REL-02` entitlement restoration; `REL-03` Windows paid distribution build; `REL-04` rights and audio source clearance; `REL-05` rating/store policy; `REL-06` privacy declaration/SDK disclosures; `REL-07` app signing + AAB; `REL-08` store metadata, staged rollout and smoke QA.

**Exit gate:** store test purchases and rewarded-ad callback QA, age/legal reviews complete, signed distribution artifacts build. Release approval remains human.

## Automated regression tests

1. P1 behind P2 -> forward resolves according to facing; mirrored hitbox correct.
2. Standing block defeats mid/high, loses to low/throw; crouch block defeats low/mid, loses to overhead/throw.
3. One attack frame overlapping multiple physics ticks still hits target only once per strike ID.
4. Valid multi-hit super registers distinct strike IDs no more than defined count.
5. Two attacks resolving same tick can result in double KO/draw.
6. HP clamps 0..max, meter clamps 0..100, super consumes meter once.
7. Attack input during stun/KO ignored; queued input expires after 6 ticks.
8. Damage scaling nonnegative, combo ends on recovery/20-tick gap.
9. Round timeout compares percent HP not raw HP; draws do not award win.
10. Pause/background freezes HP/meter/timer and clears held inputs on resume.
11. Missing audio returns subtitle/SFX fallback and never crashes.
12. Character data malformed/missing attack does not crash menu; diagnostic and safe default or disabled character.
13. AI does not violate legal move state, reacts based on visible state.
14. `clean` speech mode does not play explicit audio; toggle changes no damage/frames.
15. H+S versus heavy/S conflict resolves by documented priority and meter conditions.

## Manual release matrix

Windows 10/11: keyboard, two keyboard users, Xbox/standard controller, alt-tab, windowed/fullscreen, resolution changes, quit/restart. Android: at least one low-mid Android phone and one newer phone, safe area/notch, landscape, 16:9 to 20:9, multitouch direction+two buttons, background/resume, audio interruption, gamepad if available, offline airplane mode, 20 matches, APK/AAB install signatures. Sinhala text rendering and subtitle size on both.

## Delivery estimates (non-binding)

Phase 0+1 roughly 1–2 weeks for experienced Godot implementer, Phase 2 another 2–3 weeks, Phase 3 3–6 weeks plus art/recordings, Phase 4 1–3 weeks plus external approval/review. Combined first commercial MVP indicative 7–14 weeks or more; measurements depend heavily on asset production and testing. Codex can accelerate coding but cannot substitute for device QA and original assets.

## Required implementation reporting after each milestone

1. Files created/changed; 2. How to launch; 3. What is actually playable; 4. Automated/manual tests run and outcomes; 5. Known gaps; 6. Next recommended ticket. Do not claim successes if binaries were not executed.
