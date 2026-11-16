# Phase 0 / VS-01 actual implementation and test results

**Path migration:** this historical report records commands from before the project moved to the repository root. Preserve those commands and raw logs as evidence; use the [current root launch guide](10-WINDOWS-PROTOTYPE.md) and [migration verification](14-PROJECT-STRUCTURE.md) for today's paths.

Date: **2026-11-14** (Asia/Colombo). Scope: Phase 0 and Phase 1 of doc 08, not VS-02 or commercial MVP acceptance.

For the subsequent 2026-11-16 throw investigation, expanded tests and rebuilt Windows prototype, see [the throw check](12-THROW-CHECK.md). Results below preserve the initial milestone run.

## Environment and actual results

Executed on Windows x64, reported OS build `Microsoft Windows NT 10.0.26200.0`, using **Godot 4.7.2.stable.official.ed1daf0bf Standard**. Rendered runs reported **OpenGL 3.3.0 NVIDIA 596.52 / Compatibility / NVIDIA T600 Laptop GPU**. Matching official 4.7.2 Standard Windows x64 export templates were used. There were no pre-existing tests or installed engine on PATH; the engine/templates were downloaded into ignored workspace-local tooling.

| Check actually run | Result | Evidence |
| --- | --- | --- |
| Headless editor import/scene and script registration | PASS, exit 0, no engine/script errors in final run | [import.txt](test-results/import.txt) |
| Pure combat/data/input/round regressions | **76 assertions passed, 0 failed**, exit 0 | [combat.txt](test-results/combat.txt) |
| Real scene tree/input/HUD integration | **13 assertions passed, 0 failed**, exit 0 | [scenes.txt](test-results/scenes.txt) |
| Rendered Windows integration and four screenshot saves | **17 assertions passed, 0 failed**, exit 0 | [rendered.txt](test-results/rendered.txt) |
| Windows Desktop debug x64 export | PASS, exit 0 | [export.txt](test-results/export.txt) |
| Exported executable startup, headless, five iterations | PASS, exit 0, no missing resources/errors | [standalone-headless.txt](test-results/standalone-headless.txt) |
| Exported executable startup, graphics enabled, ten iterations | PASS, exit 0; actual Compatibility GPU renderer initialised | [standalone-rendered.txt](test-results/standalone-rendered.txt) |

The rendered integration test completes two actual KO rounds through mapped input actions, without assigning fighter HP, and verifies match results, rematch and return to menu. The pure suite separately covers attacks, stuns, timeout percentages, draw handling, simultaneous contacts and sudden death. This distinguishes scene execution from isolated logic assertions. The 17 rendered assertions repeat the 13 scene assertions and add four screenshot-save checks; they are not 17 additional distinct combat cases.

The final exported files are `builds/windows/LankaRumble.exe`, `LankaRumble.pck`, and the optional `LankaRumble.console.exe` launcher. The debug runtime executable is approximately 98 MiB; the game data pack is approximately 60 KiB. Export output contains the runtime scenes/scripts/resources and icon; reference photos, test scripts, docs, tooling and QA screenshots are excluded.

Rendered menu, arena, pause and results screenshots were saved under `builds/qa/` and visually inspected during implementation. Screenshot review identified health-bar minimum sizing that overlapped HP text; custom styles and resetting the bar size after applying the styles corrected it. A scene regression checks the actual engine-sized bar against the HP label position. No sustained FPS benchmark, minimum-hardware claim or two-human test is inferred from a short GPU run.

## Commands actually used

From the workspace root `C:\Personal\HelaGen\Projects\RumbleLanka`, the final checks used the following commands. `-Godot` can point to any local copy of the same Standard engine; the helpers derive the project path from their own location.

```powershell
$godotExe = '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$projectPath = '.\Lanka-Rumble-Codex-Specs-v1.0\lanka-rumble-specs'

& "$projectPath\tools\test.ps1" -Godot $godotExe
& "$projectPath\tools\build-windows.ps1" -Godot $godotExe

& $godotExe --path $projectPath --fixed-fps 60 --max-fps 0 --disable-vsync --resolution 1280x720 --script res://tests/run_scene_tests.gd -- --screenshots

& "$projectPath\builds\windows\LankaRumble.console.exe" --headless --quit-after 5
& "$projectPath\builds\windows\LankaRumble.console.exe" --quit-after 10 --audio-driver Dummy
```

The test helper runs `--headless --editor --import --quit`, `res://tests/run_tests.gd`, and `res://tests/run_scene_tests.gd` with a fixed 60 Hz test step. It saves output and rejects nonzero exits, `SCRIPT ERROR:`, `ERROR:` or leaked-instance diagnostics. Full command equivalents are in [the launch guide](10-WINDOWS-PROTOTYPE.md).

Initial sandboxed import attempts reported inability to create Godot's AppData directories and read the certificate store; rerunning with access to the normal engine user-data directory resolved these environment failures. Early regression runs found a malformed-content cast error and incorrect left/right key codes. Tests also exposed an incorrect attack-instance expectation in test setup. All were corrected and the complete suite rerun. An immediate-exit silent audio playback allocation produced shutdown leak diagnostics; the silent fallback now returns captions without allocating playback. The final test outputs contain none of those errors or leaks.

## What is playable / files changed

| Area | Implementation |
| --- | --- |
| Foundation | `project.godot`, `icon.svg`, `.gitignore`, `export_presets.cfg`; fixed 640x360 arena, 60 Hz physics, Compatibility renderer and Windows x64 preset |
| Entry and scenes | `scenes/main/main.tscn`, `scenes/match/match.tscn`, `scenes/fighter/fighter.tscn`, `scripts/core/game_flow.gd`; menu and scene navigation |
| Simulation | `scripts/core/match_simulation.gd`, `match_manager.gd`, `scripts/fighter/fighter_state.gd`, `scripts/combat/combat_resolver.gd`; state, movement, collision, damage and round flow |
| Input | `scripts/input/input_frame.gd`, `local_input_adapter.gd`, Input Map defaults; P1/P2 keyboard plus P2 laptop alternatives, chord/buffer and pause inhibition |
| Content | `scripts/data/*.gd`, seven `resources/attacks/*.tres`, two `resources/fighters/*.tres`, `resources/stages/debug_arena.tres`; configurable shared placeholder moves/stats |
| Presentation | `scripts/fighter/fighter_controller.gd`, `scripts/presentation/*.gd`; geometric fighters/stage, HP, timer, rounds, captions, debug hitboxes, pause/results/rematch |
| Audio/assets | `scripts/audio/placeholder_audio.gd`, `assets/audio/placeholders/silence.tres`, `assets/ASSET-MANIFEST.md`, `references/.gdignore`; safe silent fallback and preservation/exclusion of source reference art |
| Verification | `tests/run_tests.gd`, `tests/run_scene_tests.gd`, `tools/test.ps1`, `tools/build-windows.ps1`, raw result text alongside this report |
| Reporting | Updated `README.md`, `docs/09-DECISIONS-RISKS.md`; added `CHANGELOG.md`, `docs/10-WINDOWS-PROTOTYPE.md` and this report |

Standing/crouching/aerial L/H normals, low sweep and minimal grounded L+H throw work with mirrored facing, stage/body constraints, stun, nonlethal normal blocking, hitstop and single-hit instance protection. Health, KO, first-to-two rounds, percentage-health timeouts, draw restart and sudden death work. The automated tests exercise the full Start Fight -> match -> results -> rematch -> menu path. No real voices, final art, named personalities, monetisation or SDKs were added.

## Manual Windows QA checklist - pending human execution

These checks are **not marked passed** by the automated runs:

- [ ] On target Windows 10 and Windows 11 machines, launch the exported `.exe` with its `.pck`, choose Start Fight, and quit/relaunch.
- [ ] Two real humans play full first-to-two matches with P1 WASD/J/K/I and P2 arrows/numpad; check Num Lock behavior, keyboard rollover/ghosting, chords and laptop U/O/P alternatives.
- [ ] Confirm crouch guard beats sweep, standing guard loses to sweep, throw beats guard and jumping evades grounded throw; test both sides after jump cross-ups.
- [ ] Observe light/heavy startup, recovery, hit/block feedback, knockdown/getup, landing recovery and KO with F3 boxes on/off.
- [ ] Play a three-round 2-1 match as well as 2-0. Let a round reach the actual 99-second timeout; test tied draws and sudden death in real-time play.
- [ ] Pause/resume during neutral, attacks, hitstop, countdown and round result; alt-tab and release held keys before resume. Verify no stuck movement or surprise attacks.
- [ ] Resize to 16:9, ultrawide and narrow windows; check preserved arena dimensions, letterboxing, readable HUD and menu keyboard focus. Test fullscreen launch with `--fullscreen` if needed.
- [ ] Run 20 continuous human matches without crashes/softlocks, record CPU/GPU/hardware and sustained frame-time data. Current automated match execution does not satisfy this release gate.

Godot editor import and rendered runtime were executed; a human opening the editor and pressing F5 was not separately performed. Windows debug export/startup was executed; installer, code signing, Windows 10 hardware, controllers, audio-device playback, Android exports/device tests and store release checks were not performed.

## Known limits and next ticket

The VS-01 implementation is available for the human exit-gate playtest. It uses fixed geometric placeholder visuals and silent captions. There is no CPU, touch/gamepad adapter, runtime remapping/settings, Sinhala UI, saved progress, specials/projectiles, meter, super, combo scaling/cancel routes or commercial release integration. Tests 4, meter/super parts of 6/15, 8, 13 and real profanity variants in 14 from doc 08 are future-scope tests, not claimed passes. Current tests cover the scope-appropriate remainder.

Edges sampled during hitstop are discarded rather than buffered; the simulation/input-buffer clocks freeze. This reversible first-slice policy is recorded in doc 09 and should be revisited during input feel testing. Simple jump-start/visual animations also remain placeholder behavior. No claim is made about target Android performance or export size targets.

Recommended next work: run the two-human Windows checklist, then VS2-02/03 (meter, specials/projectiles and strike IDs), VS2-04 (seeded AI through InputFrame), and Android touch/export once the local slice is accepted. VS2-01's basic hit-level/throw groundwork already exists.
