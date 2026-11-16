# Windows prototype - Phase 0 / VS-01

## Launch the local executable

From the repository root, open `builds/windows/` and double-click **LankaRumble.exe**. Keep **LankaRumble.pck** in the same folder. `LankaRumble.console.exe` is an optional diagnostic launcher. Choose **Start Fight**, wait for **FIGHT!**, then play locally with two people on one keyboard.

This working copy includes a generated debug x64 build. Generated binaries are intentionally ignored by Git and will need rebuilding after a clean checkout. Copy the `.exe` and `.pck` together when moving the prototype. It runs offline and needs no Godot editor, account, SDK, paid plugin or installation of C#.

## Launch from source

1. Download **Godot 4.7.2 Standard for Windows x86_64**, not the .NET edition, from the [official archive](https://godotengine.org/download/archive/4.7.2-stable/). Unzip it.
2. In Godot's Project Manager, choose **Import** and select `project.godot` directly in the `RumbleLanka` repository root. Remove any stale entry for the former extracted specification-pack folder.
3. Open the project, allow the initial import, and press **F5**. The main scene is `scenes/main/main.tscn`.
4. Choose **Start Fight** with mouse or keyboard. Two humans control Placeholder A and Placeholder B. There is no CPU opponent in this phase.

Or, in PowerShell from the repository root, `C:\Personal\HelaGen\Projects\RumbleLanka` in this working copy (adjust the executable path):

```powershell
$godotExe = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --editor --path .
# Or run directly:
& $godotExe --path .
```

## Controls

| Action | P1 | P2 | P2 laptop alternative |
| --- | --- | --- | --- |
| Walk | A / D | Left / Right | same arrows |
| Jump / crouch | W / S | Up / Down | same arrows |
| Light | J | Num1 | U |
| Heavy | K | Num2 | O |
| Hold block | I | Num5 | P |
| Throw | J + K | Num1 + Num2 | U + O |
| Reserved special | L | Num3 | not assigned |
| Pause / resume | Esc or Enter | shared | shared |
| Collision/debug overlay | F3 | shared | debug builds |

Hold Down+heavy for a low sweep; use Down+block to guard lows. Standing block guards mid/high/overhead; crouching block guards low/mid. Guard only works on the ground, towards the attacker's side. Throws beat guard and miss airborne opponents. Jump+light/heavy uses aerial normals; landing ends their hitbox and applies 5/9 ticks of recovery.

One press starts one attack; holding it does not repeat. Initial action selection uses three input ticks. Keyboard throws accept a six-tick chord window (approximately 100 ms): keep the first attack key held while pressing the other. The normal can change into a throw during its early startup, so single-button attacks retain their original responsiveness. Priority in this slice: B+attack ignores the attack; H+S uses heavy (no super/meter yet); L+H throws; H beats L; S alone does nothing. Buffered attacks expire after six simulation ticks, cannot cancel recovery and are discarded during stun/KO/getup/landing. Guard cannot cancel an ongoing attack.

**Throw check:** `L+H` in the combat specification means the **Light and Heavy actions**, not the literal L and H letter keys. For P1, walk right up to the opponent and press **J+K together**; P2 uses **Num1+Num2** or **U+O**. Release your own block first and wait until recovery/stun ends. Both fighters must be grounded for a successful grab. Keyboard input accepts key edges sampled on the same tick or up to five ticks apart. Grab reach is shorter than a light punch: at 50 pixels or more between fighter centres it whiffs. A visible **THROW** label confirms the input was recognised; a successful hit shows **P1 threw P2 (-110 HP)** (or the reverse) and knocks the target down. Release the attack keys before trying again. The tolerance is configurable via `controls/keyboard_throw_chord_ticks` in project.godot (3..6). See [the timing fix and actual checks](13-THROW-TIMING-FIX.md).

The exact startup/active/recovery values and geometric hitboxes live in `resources/attacks/*.tres`. Fighter stats and colours live in `resources/fighters/*.tres`; stage boundaries and gravity in `resources/stages/debug_arena.tres`. Change keyboard bindings in **Project > Project Settings > Input Map**. Keyboard ghosting/rollover varies by hardware; use P2 U/O/P if there is no numpad and check actual simultaneous inputs on the target keyboard.

## Match rules

Each round starts with a 90-tick countdown. Win a round by KO or by having the higher remaining HP percentage at 99 seconds. Win two rounds to win the match. Double KO and equal percentage timeout are draws and award neither side a win. After three consecutive draws, the next round uses sudden death: first unblocked hit wins, with no timer. Simultaneous sudden-death hits draw again. Health/positions reset between rounds; match results offer **Rematch** or **Main Menu**.

Hitstop and pause freeze combat and the round clock. Losing application focus pauses; **Resume** is required. Release any held key after resume/countdown before pressing it again. Placeholder audio is deliberately silent; hit/block/KO captions provide event feedback.

## Test and export

From the project root, with Godot 4.7.2 Standard and its matching **Standard export templates** installed using **Editor > Manage Export Templates**:

```powershell
.\tools\test.ps1 -Godot $godotExe
.\tools\build-windows.ps1 -Godot $godotExe
& .\builds\windows\LankaRumble.console.exe --headless --quit-after 5
# Interactive standalone launch:
& .\builds\windows\LankaRumble.exe
```

The helpers work independently of the current directory, use the supplied engine path, and fail on engine errors as well as a nonzero exit code. Tests save output under `builds/test-results/`. The build helper uses the **Windows Desktop** preset and creates the output directory. Templates must match 4.7.2 exactly. This is an unsigned debug prototype, without resource branding/signing tools or an installer.

Equivalent headless commands:

```powershell
& $godotExe --headless --path . --editor --import --quit
& $godotExe --headless --path . --script res://tests/run_tests.gd
& $godotExe --headless --fixed-fps 60 --max-fps 0 --path . --script res://tests/run_scene_tests.gd
New-Item -ItemType Directory -Force builds/windows | Out-Null
& $godotExe --headless --path . --export-debug 'Windows Desktop' builds/windows/LankaRumble.exe
```

Optional rendered scene checks and screenshot capture (opens a temporary game window):

```powershell
& $godotExe --path . --fixed-fps 60 --max-fps 0 --script res://tests/run_scene_tests.gd -- --screenshots
```

Do not interact with the temporary test window during automation; focus changes intentionally pause a match. Screenshots are written to `builds/qa/`. For human play use normal launch, without `--fixed-fps`, which is an automated testing mode.

## Code boundaries and next increment

`InputFrame`/`LocalInputAdapter` own device translation; `FighterState` owns movement/state/attack counters; `MatchSimulation` owns tick order and contacts; `CombatResolver` owns guard and damage; `MatchManager` owns rounds/timer. `FighterController`, `MatchView`, `FightHUD` and `PlaceholderAudio` present those results. `GameFlow` switches screens. Pure simulation scripts can run without the scene tree. Hit/hurt detection uses explicit frame-driven rectangles, as permitted in doc 02, and never relies on asynchronous physics callbacks.

VS-02 should extend the existing canonical interface with seeded AI and touch, then meter, specials/projectiles and super strike IDs. The simple shared throw already covers the VS-01 guard exception. Named-fighter content, Android exports, controllers, localisation, saved settings and advanced combo/cancel rules remain later work. Monetisation, real voices and final art remain outside this slice.
