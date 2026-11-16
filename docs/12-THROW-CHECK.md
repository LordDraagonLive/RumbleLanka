# Throw investigation - 2026-11-16

**Path migration:** command snippets below retain their original extracted-pack paths as historical evidence. The current project is at the repository root; see the [launch guide](10-WINDOWS-PROTOTYPE.md) and [structure report](14-PROJECT-STRUCTURE.md).

**Follow-up:** after this initial investigation, the user confirmed correct J+K input still produced a punch. Reproducing slower key edges exposed a timing usability failure; keyboard tolerance has since been corrected. This report preserves the earlier strict-window checks. See [the current timing fix and results](13-THROW-TIMING-FIX.md).

The reported throw failure was not reproduced through Godot's keyboard mapping and combat simulation. **P1 J+K, P2 Num1+Num2 and P2 U+O all start a throw, deal 110 damage once, and knock a grounded target down.** They work on both sides and bypass ordinary guard.

The visible help previously said `L+H throw`, which describes the abstract Light and Heavy actions and can be mistaken for literal letter keys. The placeholder grab also looked like a normal punch and its event caption only said "hit". These presentation problems are corrected: the menu/HUD show actual keys and close-range guidance, attempted grabs display **THROW**, successful grabs report who threw whom and the HP loss, and F3 displays the current attack ID.

No key bindings, throw damage, reach or combat timing were changed. Walk right up to the other fighter, release your own block, wait for recovery/stun to finish and press **J+K together** for P1, or **Num1+Num2 / U+O** for P2. Release both before trying again. Do not use the literal L and H letter keys.

## Constraints verified

- Both button edges must arrive within the three sampled ticks: the same tick or two ticks apart. A second edge three ticks later is outside the window and starts an ordinary normal instead. This is approximately a 50 ms sampling window at 60 Hz; it is intentionally unchanged from doc 02.
- With the current 32-pixel-wide hurtboxes and throw rectangle, 49 pixels between fighter centres connects; 50 pixels does not. Normal punching range is longer. A visible THROW without damage indicates a recognised attempt that missed or met an ineligible target.
- Throws beat held opponent guard. They miss airborne targets and cannot target hitstun, blockstun, knockdown or getup. Your own block suppresses attack inputs. Holding the chord does not automatically repeat throws.
- The throw remains 7 startup / 2 active / 20 recovery ticks, 110 damage, 6 hitstop ticks and knockdown. These values are in `resources/attacks/throw.tres`, shared by both placeholder fighter resources.

## Actual checks

Executed with **Godot 4.7.2.stable.official.ed1daf0bf Standard** on Windows. Rendered checks used Compatibility / OpenGL 3.3 / NVIDIA T600 Laptop GPU.

| Check | Actual result | Raw output |
| --- | --- | --- |
| Import/parse | PASS, exit 0 | [import](test-results/2026-11-16/import.txt) |
| Existing combat regressions | 76 passed, 0 failed | [combat](test-results/2026-11-16/combat.txt) |
| New physical-key throw suite | **20 passed, 0 failed** | [throws](test-results/2026-11-16/throws.txt) |
| Expanded live-scene integration | 15 passed, 0 failed | [scenes](test-results/2026-11-16/scenes.txt) |
| Rendered scene integration + six screenshots | 21 passed, 0 failed | [rendered](test-results/2026-11-16/throw-rendered.txt) |
| Windows x64 debug export | PASS, exit 0 | [export](test-results/2026-11-16/throw-export.txt) |
| Rebuilt standalone headless startup | PASS, exit 0, five iterations | [standalone](test-results/2026-11-16/throw-standalone.txt) |

The dedicated suite injects `InputEventKey` physical key events through `Input.parse_input_event`, the actual Input Map, `LocalInputAdapter` and `MatchSimulation`; it never forces attack state or active frames. It covers all three bindings at same-tick, one-tick and two-tick offsets; reversed facing; heavy-first chords; guard; inside/outside grab range; an airborne target; own-block suppression; literal L+H; and holding keys without repeated throws. Events are synthetic: a human's physical keyboard rollover/ghosting has not been tested.

The live scene walks back into range after a heavy, presses light+heavy through its normal adapters, recognises a grab, throws a guarding opponent from 900 to 790 HP, observes knockdown, and verifies the throw caption. Rendered screenshots were inspected for the attempt label, guard, successful hit, HP and caption: [attempt](test-results/2026-11-16/throw_attempt.png), [hit](test-results/2026-11-16/throw_hit.png). The 21 rendered checks repeat the 15 scene checks plus six screenshot saves.

Commands, from workspace root:

```powershell
$godotExe = '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$projectPath = '.\Lanka-Rumble-Codex-Specs-v1.0\lanka-rumble-specs'
& "$projectPath\tools\test.ps1" -Godot $godotExe
& $godotExe --path $projectPath --fixed-fps 60 --max-fps 0 --disable-vsync --resolution 1280x720 --script res://tests/run_scene_tests.gd -- --screenshots
& "$projectPath\tools\build-windows.ps1" -Godot $godotExe
& "$projectPath\builds\windows\LankaRumble.console.exe" --headless --quit-after 5
```

The rebuilt playable executable is `builds/windows/LankaRumble.exe`; keep its freshly rebuilt `.pck` beside it. Close any old running copy and launch it again. Source changes are in `game_flow.gd`, `fight_hud.gd`, `fighter_controller.gd`, `match_view.gd`; tests are in `run_throw_tests.gd` and `run_scene_tests.gd`, and `tools/test.ps1` now includes the throw suite. README, launch guide, decision log and changelog were updated.

Manual follow-up: try each player's combination on the actual keyboard while grounded, close enough, not guarding and out of stun/recovery. If it still fails, F3 now distinguishes an unrecognised chord (`light`/`heavy` or idle) from a recognised `throw` that missed. Physical key rollover and human input feel remain unverified.
