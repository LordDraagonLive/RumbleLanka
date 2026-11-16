# Changelog

## 2026-11-16 - Repository-root project structure

- Moved the Godot project, scenes, scripts, Resources, runtime assets, tests, automation, docs, examples, prompts and references directly to the repository root. Removed the empty extracted-pack wrapper directories.
- Preserved res:// paths, .uid sidecars, content, reference media and historical test evidence. All 106 source-file hashes matched immediately after the move, before documentation edits.
- Moved generated builds/QA output to root builds/. Archived former editor/import data and ignore files in ignored .tools/migrations, and regenerated the root import cache.
- Consolidated Git ignores; excluded local tooling and non-runtime documentation/samples from Godot scanning. Rewrote the root README around the runnable project, retained the specification overview in docs/00-SPECIFICATION-OVERVIEW.md, and updated root launch/export instructions.
- See docs/14-PROJECT-STRUCTURE.md for current paths and post-move checks. Gameplay and deferred throw visuals are unchanged.

## 2026-11-16 - Keyboard throw timing fix

- Reproduced the user's J+K-to-punch symptom with attack key edges three to five frames apart. The earlier check only established that tighter chords worked.
- Increased keyboard throw tolerance to six ticks (about 100 ms) without delaying single-button normal startup. Grounded normals explicitly opt into an early-startup chord correction through AttackDefinition; active/recovery frames cannot be cancelled. Both keys must remain held, and guard/special input, release, air and stun prevent correction.
- Added configurable `controls/keyboard_throw_chord_ticks` (3..6); canonical action-frame defaults retain three ticks. Damage, throw reach, hitstop and single-hit rules are unchanged.
- Expanded physical-key tests to 38 cases and changed live scene integration to use staggered input. Before/after results and Windows build verification are in `docs/13-THROW-TIMING-FIX.md`.

## 2026-11-16 - Throw input investigation and feedback

- Reproduced throws through physical key events, the Input Map, keyboard adapter and full simulation for P1 J+K, P2 Num1+Num2 and P2 U+O. Mapping and damage are correct; the previous on-screen `L+H` shorthand could be mistaken for literal letter keys.
- Replaced shorthand in the menu/HUD with actual key combinations and close-range instructions. Added a visible THROW attempt label, a successful-throw caption, and attack IDs in the F3 overlay. Combat timing, reach and damage remain unchanged.
- Added a 20-case physical-key throw suite covering both sides, chord timing/order, guard, range, airborne targets, own block suppression and no held-repeat. Extended live scene checks to cover a throw attempt and successful guarded-target throw. Actual results and Windows build verification are in `docs/12-THROW-CHECK.md`.

## 2026-11-14 - Phase 0 and Phase 1 / VS-01

- Added a Godot 4.7.2 Standard project: Compatibility renderer, 640x360 fixed arena, 1280x720 default window, 60 Hz physics, 60 FPS cap, Windows x64 export preset.
- Added Start Fight/Quit, a geometric stage, two labelled colour-coded placeholders, HP and round HUD, pause/resume, match result, rematch and return to menu.
- Separated canonical input frames and keyboard mapping, frame-driven fighter state, simulation, collision resolution, round management, Resource-backed content and drawing.
- Implemented facing, walking, jumping/cross-ups, crouching, floor/wall/body constraints, standing/crouching/aerial light and heavy normals, sweep, minimal guard-bypassing grounded throw, startup/active/recovery frames and landing recovery.
- Added block hit-level checks, hit/block stun, knockdown/getup, hitstop, one-hit-per-attack-instance protection and simultaneous contact collection for trades/double KO.
- Added a 99-second timer frozen by pause/hitstop; best-of-three rounds, percentage-health timeouts, no-win draws, and sudden death after three consecutive draws.
- Added a three-tick chord window, six-tick expiring attack buffer, no held auto-repeat, stun/KO input rejection and held-input inhibition across pause/round transitions.
- Added authored silence and captions as audio fallback; excluded reference photographs and non-runtime documentation from exports.
- Added combat and scene regression scripts, PowerShell test/build helpers, Windows launch instructions and an actual-results/manual-QA report. Built and smoke-launched the Windows executable with Godot 4.7.2.

No monetisation, network access, real voice, final character art, named fighters, AI, touch, specials or supers were added.
