# Lanka Rumble

A Godot **4.7.2 Standard / GDScript** 2D fighting-game prototype. Phase 0 and Phase 1 (VS-01) are implemented: two labelled placeholder fighters, local keyboard play, movement, light/heavy attacks, guard, throws, HP, a 99-second clock, first-to-two rounds, pause and rematch.

**The repository root is the Godot project root.** Open the `project.godot` beside this README. Specifications live in `docs/`; game code does not belong in an extracted specification-pack directory.

## Run on Windows

1. Open Godot **4.7.2 Standard**, choose **Import**, and select this repository's `project.godot`.
2. Allow the initial import, then press **F5** and choose **Start Fight**.
3. Play with two people on one keyboard. There is no CPU opponent yet.

If you used the former nested project, remove its stale entry from Godot's Project Manager and import the root project instead. The game has moved; its `res://` paths and fighter data are unchanged.

A generated Windows build may be present at `builds/windows/LankaRumble.exe`. Keep `LankaRumble.pck` beside it. It runs offline without the editor. Builds, engine downloads and import caches are intentionally ignored by Git and need recreating on a fresh checkout.

| Action | P1 | P2 |
| --- | --- | --- |
| Walk / jump / crouch | WASD | Arrow keys |
| Light / heavy / block | J / K / I | Num1 / Num2 / Num5, or U / O / P |
| Throw, up close | J+K | Num1+Num2, or U+O |
| Sweep | Down+heavy | Down+heavy |
| Pause / resume | Esc or Enter | Shared |
| Debug hitboxes and attack ID | F3 | Shared, debug builds |

Keyboard throws allow about 100 ms between attack keys; keep the first held until the second arrives. Release block and wait for stun/recovery to end. Placeholder throw animation and final character art remain later work. Special keys are reserved for Phase 2. Audio is intentionally silent with captions.

See the [Windows launch and export guide](docs/10-WINDOWS-PROTOTYPE.md) for detailed controls, timing, and match rules.

## Repository layout

```text
RumbleLanka/
  project.godot              # Single Godot project entry point
  export_presets.cfg         # Windows x64 export configuration
  AGENTS.md                  # Repository development instructions
  README.md
  CHANGELOG.md
  icon.svg
  scenes/                    # Main, match and fighter scenes
  scripts/
    core/                    # Game flow, simulation and round management
    fighter/                 # Fighter state and placeholder actor view
    combat/                  # Contact, guard and damage resolution
    input/                   # Canonical InputFrame and keyboard adapter
    data/                    # Resource type definitions
    presentation/            # Stage, HUD and screen presentation
    audio/                   # Silent placeholder events and captions
  resources/                 # Fighter, attack and stage .tres data
  assets/                    # Runtime assets and provenance manifest
  tests/                     # Godot combat, throw and scene regression runners
  tools/                     # PowerShell test and export helpers
  docs/                      # Specifications, decisions, reports and QA
  examples/                  # Original specification data examples
  prompts/                   # Original implementation handoff
  references/                # Non-runtime art references; not exported
  builds/                    # Generated Windows builds, QA output (ignored)
  .godot/                    # Regenerated Godot import/editor cache (ignored)
  .tools/                    # Local engine, templates and migration backup (ignored)
```

`tools/` is maintained automation; `.tools/` is disposable local tooling. Documents, examples, prompts and reference media are excluded from Godot asset scanning and from Windows exports. Create future systems when their phase needs them; do not create a second Godot project or duplicate the current source tree.

## Test and build

From this repository root, supply the path to a Godot 4.7.2 Standard executable:

```powershell
$godotExe = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
# This working copy also has an ignored local engine:
# $godotExe = (Resolve-Path '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe').Path

& $godotExe --editor --path .
.\tools\test.ps1 -Godot $godotExe
.\tools\build-windows.ps1 -Godot $godotExe
& .\builds\windows\LankaRumble.console.exe --headless --quit-after 5
```

Install the matching **4.7.2 Standard export templates** with **Editor > Manage Export Templates** before exporting. No C#, third-party addon, network service, login or SDK is required for the prototype. The helpers derive the project root from their own location and write output under `builds/`.

## Specifications and implementation status

- [Specification overview and reading order](docs/00-SPECIFICATION-OVERVIEW.md)
- [Normative combat rules](docs/02-GAMEPLAY-COMBAT.md) and [architecture](docs/04-TECHNICAL-ARCHITECTURE.md)
- [Backlog and phase exit gates](docs/08-BACKLOG-TEST-PLAN.md)
- [Decisions and known risks](docs/09-DECISIONS-RISKS.md)
- [Initial milestone test results and manual QA](docs/11-TEST-RESULTS.md)
- [Keyboard throw timing fix](docs/13-THROW-TIMING-FIX.md)
- [Root-layout migration and current verification](docs/14-PROJECT-STRUCTURE.md)
- [Changelog](CHANGELOG.md)

Named-fighter content, CPU, touch, specials/supers, Android exports, localisation and final throw/character animations remain future phases. Monetisation, real voices and final art are not included. Human keyboard and target-hardware QA remain separate from automated checks.
