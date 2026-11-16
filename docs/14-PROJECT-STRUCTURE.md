# Repository-root project structure - 2026-11-16

The Git/workspace root is now the Godot project root:

```text
C:\Personal\HelaGen\Projects\RumbleLanka\project.godot
```

The former `Lanka-Rumble-Codex-Specs-v1.0/lanka-rumble-specs/` wrapper was removed after moving its contents and verifying both wrapper directories were empty. This follows the layout in doc 04. There is one project entry point and one implementation tree.

## Ownership and placement

| Root path | Owns |
| --- | --- |
| `project.godot`, `icon.svg`, `export_presets.cfg` | Engine configuration, entry scene and Windows x64 export |
| `scenes/` | Main, match and fighter scene composition |
| `scripts/core/` | Screen flow, authoritative simulation and match/round lifecycle |
| `scripts/fighter/` | Fighter state and placeholder actor presentation |
| `scripts/combat/` | Contact collection, guard and damage rules |
| `scripts/input/` | Canonical action frames and device adapters |
| `scripts/data/`, `resources/` | Resource definitions and configurable fighter/attack/stage content |
| `scripts/presentation/`, `scripts/audio/`, `assets/` | Stage/HUD views, silent event fallback and runtime assets |
| `tests/` | Existing headless combat, physical-key throw and live-scene runners |
| `tools/` | Maintained PowerShell testing and Windows export scripts |
| `docs/` | Specifications, decisions, historical evidence and current reports |
| `examples/`, `prompts/`, `references/` | Original specification examples, agent handoff and non-runtime art references |
| `AGENTS.md`, `README.md`, `CHANGELOG.md`, `.gitignore` | Repository-wide instructions, launch guide, change history and ignore rules |
| `builds/` | Generated executable/package, QA captures and test output; ignored by Git |
| `.godot/` | Regenerated import/editor cache; ignored by Git |
| `.tools/` | Local engine/templates and migration backup; ignored by Git |

Do not confuse maintained `tools/` with local `.tools/`. Documents, prompts, examples, local tooling and reference media have `.gdignore` markers; export filters exclude non-runtime material. Future-phase systems should be added within this structure when needed rather than creating another project.

## Preservation and scope

Before moving, a SHA-256 inventory recorded **106 source/evidence files**, including scenes, code, data, .uid files, examples, docs, test logs and original references. All 106 matched byte-for-byte immediately after relocation and before intentional documentation changes. A subsequent integrity check compares the runtime/configuration, tests, helpers and original references with that inventory. [The pre-move inventory](test-results/2026-11-16/root-layout/source-hashes-before.json) and [structure checks](test-results/2026-11-16/root-layout/structure.txt) are retained as evidence.

Existing `res://` resource paths and script .uid sidecars remain unchanged because paths relative to the project root did not change. No GDScript, scene, fighter/attack data, combat behavior or throw animation was changed by this migration. Existing uncommitted work was moved with the project; no Git staging or commit was performed.

Generated Windows builds and QA artifacts moved to root `builds/`. The former .godot cache, four empty editor-created directories, old ignore files and previous project README were preserved in ignored `.tools/migrations/root-layout-2026-11-16/`. The new root import cache was regenerated instead of reusing old editor state.

The root README now describes the runnable game and repository layout. [The specification overview](00-SPECIFICATION-OVERVIEW.md) retains the original product context and reading order. Docs 11-13 and their raw logs retain paths actually used in previous runs; migration notices direct readers to the current launch guide. Historical evidence was not rewritten to pretend earlier tests ran from the new location.

## Checks actually executed after the move

Godot **4.7.2.stable.official.ed1daf0bf Standard**, Windows x64. Rendered runs reported Compatibility / OpenGL 3.3 / NVIDIA T600 Laptop GPU.

| Check | Actual result | Evidence |
| --- | --- | --- |
| Fresh import at repository root | PASS, exit 0; class registration and icon import succeeded without the old cache | [import](test-results/2026-11-16/root-layout/import.txt) |
| Combat/data/input/round regressions | **76 passed, 0 failed** | [combat](test-results/2026-11-16/root-layout/combat.txt) |
| Physical-key throw regressions | **38 passed, 0 failed** | [throws](test-results/2026-11-16/root-layout/throws.txt) |
| Headless scene integration | **15 passed, 0 failed** | [scenes](test-results/2026-11-16/root-layout/scenes.txt) |
| Rendered scene integration and six screenshot saves | **21 passed, 0 failed** | [rendered](test-results/2026-11-16/root-layout/root-rendered.txt) |
| Windows x64 debug export from root | PASS, exit 0 | [export](test-results/2026-11-16/root-layout/root-export.txt) |
| Root executable headless startup | PASS, exit 0, five iterations | [headless](test-results/2026-11-16/root-layout/root-standalone.txt) |
| Root executable graphical startup | PASS, exit 0, ten iterations; Compatibility GPU renderer initialised | [graphics](test-results/2026-11-16/root-layout/root-standalone-rendered.txt) |
| Structure/content audit | Root project uniqueness, preserved runtime/config/reference hashes, existing static scene/Resource paths, documentation links, ignored generated directories and tracked-source visibility checked | [structure](test-results/2026-11-16/root-layout/structure.txt) |

The rendered checks repeat the headless scene checks and add six screenshot-save assertions. They include the full two-KO-round match, staggered-key throw, pause/resume, rematch and return to menu. These checks establish post-move execution; they do not replace pending two-human keyboard, Windows 10/11 target-device or 20-match release QA.

Commands actually used, from `C:\Personal\HelaGen\Projects\RumbleLanka`:

```powershell
$godotExe = '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
.\tools\test.ps1 -Godot $godotExe
.\tools\build-windows.ps1 -Godot $godotExe
& $godotExe --path . --fixed-fps 60 --max-fps 0 --disable-vsync --resolution 1280x720 --script res://tests/run_scene_tests.gd -- --screenshots
& .\builds\windows\LankaRumble.console.exe --headless --quit-after 5
& .\builds\windows\LankaRumble.console.exe --quit-after 10 --audio-driver Dummy
```

## Open and launch now

Import **the root project.godot** in Godot 4.7.2 and press **F5**. Remove the stale Project Manager entry for the former nested directory. For this working copy, the executable is now **builds/windows/LankaRumble.exe** with **LankaRumble.pck** beside it. The fighter file formerly open under the spec folder is now **resources/fighters/placeholder_a.tres**.

See [the README](../README.md) and [Windows guide](10-WINDOWS-PROTOTYPE.md) for current instructions. No next-phase implementation was started; throw animation polish remains deferred as requested.
