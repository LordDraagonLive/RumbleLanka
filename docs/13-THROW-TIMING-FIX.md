# Keyboard throw timing fix - 2026-11-16

**Path migration:** the game has since moved to the repository root. Commands below preserve the paths actually used for this earlier fix. Use the [current launch guide](10-WINDOWS-PROTOTYPE.md) and [migration verification](14-PROJECT-STRUCTURE.md) for root-relative commands and the latest build.

The user's clarification was **P1 J+K produces a light/heavy punch**. This exposed a real input-timing usability problem that the initial investigation did not address: key edges three to five ticks apart missed the strict three-tick grouping window and committed a normal. The first throw tests only proved that tighter timing worked.

## Result and behavior

Keyboard throw chords now accept **six sampled ticks**, approximately 100 ms: press J+K (P1), Num1+Num2 or U+O (P2), keeping the first key held until the other arrives. Offsets of zero through five ticks are accepted. Six ticks apart is outside the window.

Single-button normals retain their original selection and active-frame timing. The normal still starts after the original three-tick grouping; if its second button arrives slightly later, an explicitly permitted grounded normal's early startup changes into a throw. This correction happens before a normal hitbox can deal damage, and the throw starts its full seven-tick startup at that point. No light-plus-throw double damage is possible.

Only the four shared grounded light/heavy/crouching normal Resources opt into this correction through `AttackDefinition.allow_throw_chord_upgrade`. A released first key, guard or special input, expired input window, airborne attacker, stun or an active/recovery frame prevents it. Buffered input consumes its remaining grace instead of restarting the input window. Canonical `InputFrame` defaults retain three ticks; keyboard adapters supply the extra tolerance through the same action-frame contract.

Set `controls/keyboard_throw_chord_ticks` in project.godot to 3..6 to tune or revert it. Default is 6. The initial decision in doc 12 to retain strict keyboard timing is superseded by this confirmed user symptom and reproduced failure. Throw damage (110), range, active/recovery/hitstop timings, guard bypass and knockdown remain unchanged.

## Actual validation

Godot **4.7.2.stable.official.ed1daf0bf Standard**, Windows x64. Rendered checks reported Compatibility / OpenGL 3.3 / NVIDIA T600 Laptop GPU.

| Executed check | Actual result | Evidence |
| --- | --- | --- |
| Before-fix reproduction | **21 passed, 11 failed** in the then-32-case suite; failures were delayed light-first and heavy-first throw attempts | [before](test-results/2026-11-16/chord-fix/throw-timing-before.txt) |
| Final physical-key throw suite | **38 passed, 0 failed** | [throws](test-results/2026-11-16/chord-fix/throws.txt) |
| Existing combat/data/input/round tests | **76 passed, 0 failed** | [combat](test-results/2026-11-16/chord-fix/combat.txt) |
| Headless live scene integration | **15 passed, 0 failed** | [scenes](test-results/2026-11-16/chord-fix/scenes.txt) |
| Rendered live scene integration and six screenshot saves | **21 passed, 0 failed** | [rendered](test-results/2026-11-16/chord-fix/throw-timing-rendered.txt) |
| Import/script registration | PASS, exit 0 | [import](test-results/2026-11-16/chord-fix/import.txt) |
| Windows x64 debug export | PASS, exit 0 | [export](test-results/2026-11-16/chord-fix/throw-timing-export.txt) |
| Rebuilt standalone headless startup | PASS, exit 0, five iterations | [headless](test-results/2026-11-16/chord-fix/throw-timing-standalone.txt) |
| Rebuilt standalone graphical startup | PASS, exit 0, ten iterations; Compatibility GPU renderer initialised | [graphics](test-results/2026-11-16/chord-fix/throw-timing-standalone-rendered.txt) |

The physical-key suite uses synthetic `InputEventKey` events through the actual Input Map and keyboard adapters, not forced attacks. It verifies all three bindings at offsets 0..5, heavy-first chords, swapped facing, single-hit damage, guard bypass, range/air restrictions, held-repeat prevention, key-release suppression, expiry at tick 6, late heavy input rejection, Resource opt-out and strict three-tick adapter configuration. Tests explicitly preserve the single-light first hit at tick 7 and single-heavy first hit at tick 14, with the first attack starting at tick 2 in each zero-based sequence.

The live scene now staggers light and heavy by five physics ticks rather than pressing both on the same frame. It confirms a throw, a guarding target losing exactly 110 HP, knockdown, caption, and the complete match/rematch flow. The rendered run repeats these checks and saves screenshots. Final checks reported no script errors or instance leaks. Human keyboard hardware rollover and actual human play feel remain unverified.

Commands actually used, from the workspace root:

```powershell
$godotExe = '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$projectPath = '.\Lanka-Rumble-Codex-Specs-v1.0\lanka-rumble-specs'
# First run before changing combat failed as documented above:
& $godotExe --headless --path $projectPath --script res://tests/run_throw_tests.gd
# Complete suite after the fix:
& "$projectPath\tools\test.ps1" -Godot $godotExe
& $godotExe --path $projectPath --fixed-fps 60 --max-fps 0 --disable-vsync --resolution 1280x720 --script res://tests/run_scene_tests.gd -- --screenshots
& "$projectPath\tools\build-windows.ps1" -Godot $godotExe
& "$projectPath\builds\windows\LankaRumble.console.exe" --headless --quit-after 5
& "$projectPath\builds\windows\LankaRumble.console.exe" --quit-after 10 --audio-driver Dummy
```

Implementation changes: `scripts/input/input_frame.gd`, `local_input_adapter.gd`, `scripts/data/attack_definition.gd`, `scripts/fighter/fighter_state.gd`, the four grounded normal `.tres` files, and project.godot. Regression changes: `tests/run_throw_tests.gd` and `run_scene_tests.gd`. Combat rules, decisions, launch guide, earlier investigation notice and changelog document the revised timing policy.

## Run and manually confirm

Close the old running game and relaunch **builds/windows/LankaRumble.exe**, keeping its rebuilt **LankaRumble.pck** beside it. Walk close, release block, then press **J+K nearly together** while keeping the first key down. The visible THROW label should now appear for slightly staggered presses that previously punched. Damage/knockdown still require a grounded opponent in short grab range.

Manual QA still to perform on the user's actual keyboard: try J-first and K-first chords repeatedly, compare standalone J/K responsiveness, verify no repeated throw while held, and check a normal still happens when the second key is deliberately late. There is no need to change the bindings.
