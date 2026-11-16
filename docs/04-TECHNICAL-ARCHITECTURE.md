# 04 — Technical Architecture / Godot Implementation

## 1. Stack and baseline

Godot 4.7.2 **stable** (as of 2026-11-14), GDScript, Compatibility renderer, 2D nodes, no third-party frameworks required for core. Git. Primary Windows dev with Android SDK and JDK 17; automated tests via Godot headless where suitable. No C# needed, to minimize Android/platform surprises.

## 2. Godot project config targets

Internal viewport **640×360** (16:9) for initial arena and HUD. `viewport` stretch + `keep` aspect initially to prevent unfair horizontal visibility across ultrawide devices; letterbox/pillarbox as necessary. Integer scaling on desktop where practical; mobile may require fractional scaling to use sufficient screen area, so test visual artifacts before making integer mandatory. Nearest-neighbour texture filtering for pixel sprites. Physics ticks per second = 60, target renderer FPS 60. Android **landscape**. Respect cutouts/safe areas for touch buttons. Keep arena world frame consistent between phones and PCs.

## 3. Proposed directory structure

```text
project.godot
icon.svg
AGENTS.md
scenes/
  main/main.tscn
  menu/main_menu.tscn
  menu/character_select.tscn
  match/match.tscn
  match/stage_base.tscn
  fighter/fighter.tscn
  ui/fight_hud.tscn
  ui/mobile_controls.tscn
  ui/results.tscn
scripts/
  core/game_flow.gd
  core/match_manager.gd
  core/match_simulation.gd
  fighter/fighter_controller.gd
  fighter/fighter_state_machine.gd
  combat/combat_resolver.gd
  combat/hitbox.gd
  combat/hurtbox.gd
  combat/projectile.gd
  input/input_frame.gd
  input/local_input_adapter.gd
  input/ai_input_adapter.gd
  input/mobile_input_adapter.gd
  ai/fighter_ai.gd
  data/fighter_definition.gd
  data/attack_definition.gd
  audio/dialogue_manager.gd
  audio/audio_manager.gd
  storage/save_manager.gd
  monetization/monetization_provider.gd
  monetization/null_monetization_provider.gd
resources/fighters/ resources/attacks/ resources/stages/
assets/fighters/ assets/stages/ assets/ui/ assets/audio/placeholders/
localization/en.csv localization/si.csv
tests/ docs/
```

Names are a blueprint; agent may refine without violating boundaries.

### Implemented repository placement (2026-11-16)

`project.godot` and the directories above belong directly at the Git/workspace root, alongside README.md and AGENTS.md. Specifications remain in root `docs/`; original samples, handoff prompts and reference media remain in `examples/`, `prompts/` and `references/`. The versioned specification-pack extraction wrapper is no longer part of the project path. Godot paths such as `res://scripts/core/match_simulation.gd` retain the same meaning.

Maintained PowerShell automation lives in `tools/`. Local engine downloads, export templates and migration backups live in ignored `.tools/`; builds and QA output live in ignored `builds/`. Regenerate `.godot/` after moving the project. Non-runtime directories have `.gdignore` markers and export exclusions. Only phase-implemented systems exist; proposed future scene/system names above do not imply those features are implemented. See [the root-layout report](14-PROJECT-STRUCTURE.md) for actual ownership and verification.

## 4. Ownership boundaries

- `GameFlow`: transitions between menus/match/results; never calculates attack damage.
- `MatchManager`: round lifecycle, timer, best-of-three, arcade progress; never reads raw keyboard state.
- `MatchSimulation`: authoritative fixed-step tick and event queue; instantiates fighters, takes two `InputFrame`s.
- `FighterController`: movement, state machine, animation callbacks/presentation. Does not handle monetization.
- `CombatResolver`: shared hit/guard/throw/armour/meter/KO logic; independently testable using data.
- `InputAdapter`: converts actual physical inputs into canonical per-player frame. Implement keyboard+pad, touch and AI adapters; no AI cheating.
- `DialogueManager`: listens to event bus, selects `DialogueEntry`, chooses variant, subtitles and placeholder if asset missing; never affects damage.
- `SaveManager`: local `user://` settings + progress with schema version, safe defaults, atomic-ish write/temp and validation.
- `MonetizationProvider`: `is_ad_free`, `can_show_rewarded`, `show_rewarded`, `restore_purchases`. Null provider in dev/Windows. Android adapter later.

## 5. Scene contracts

`fighter.tscn`: Node2D or CharacterBody2D root, sprite/AnimatedSprite2D, hurtbox children, attack origin, shadow, audio emitter, state machine. Use **fighter body movement** for x, y and collision against floor; hit registration separate. Two fighter instances on `match.tscn`. `match.tscn` contains stage, camera, HUD, mobile touch UI conditional, MatchManager or parent script, optional debug overlay. Camera fixed for MVP with mild shake and no gameplay-changing zoom; super camera zoom never changes hitbox world positions.

## 6. InputFrame shape

`player_id`, `tick`, `direction_x` (-1,0,+1), `direction_y` (-1,0,+1), held bitmask/buttons, just_pressed bitmask, just_released bitmask, source. Relative forward resolved by simulation using facing. Avoid relying on Godot `Input` singleton inside fighter scripts. Handle touch multi-press without blocking opposite screen region; keyboard P1 default WASD+J/K/L/I, P2 arrows+Num1/Num2/Num3/Num5 subject to conflict testing; gamepad standard D-pad/left stick and south/east/west/north/triggers mapping set during implementation.

## 7. Signals/event contract

`attack_started(fighter_id, attack_id, tick)`, `hit_confirmed(attacker, defender, attack_id, damage, blocked)`, `fighter_damaged(fighter_id, hp)`, `meter_changed(fighter_id, value)`, `fighter_ko(fighter_id)`, `round_started(number)`, `round_ended(winner_or_draw)`, `match_ended(winner)`, `dialogue_requested(fighter_id, event_key)`. Events should be emitted once for each logical event and render effects listen without mutating combat results.

## 8. Combat implementation notes

Use one `attack_instance_id` each time a move starts and victim hit registry keyed by `(attack_instance_id, strike_id, victim_id)` to prevent multiple hits from overlapping `Area2D` collision callbacks. For repeated specials, strike IDs are distinct. Use `Area2D` shapes for hit/hurt detection but schedule on the fixed physics tick; when both players hit at once collect then apply results, so simultaneous KO works. Hitstop freezes local fighter action timers; projectiles freeze during global hitstop by policy for v1. Do not use visual animation completion as authoritative frame timings.

## 9. Data and persistence

Use Godot `.tres` Resources for Fighter/Attack/Stage definitions; `DialogueEntry` may use JSON/CSV to support translators and MP3 mapping. Local saves `user://settings.json` and `user://progress.json` with `schema_version`, reject malformed fields and default gracefully. Never hard-code five fighter branches in combat engine. Android entitlement receipt handled by store API, never a manually editable boolean alone for security-sensitive purchases.

## 10. Build pipelines

Development on Windows: install Godot 4.7.2 standard + export templates; install Android Studio SDK and OpenJDK 17; configure Android SDK/JDK paths in Godot Editor Settings. Debug APK through Godot export presets, AAB release after signing. Windows x64 release binary through export preset. Keep package ID as `com.example.lankarumble` placeholder until real developer/publisher identity is decided. No signing keys or keystore passwords in Git. Verify platform minimum SDK / target SDK / billing dependency requirements at **release time** because stores change these. Use CI when repository exists, no mandatory CI dependency for first local prototype.

## 11. Testability

Create lightweight script unit tests (or in-engine test runner) for action priority, attack registry, block hit levels, meter clamp, simultaneous KO, round timeout HP ratio, combo scaling and AI legal actions. Headless Godot tests may validate load/Resource parse; **device input and exports still require real-device smoke tests**. Render active hitboxes in debug mode, disabled in release.

## 12. Performance

Default low draw-call sprite backgrounds, compressed textures, limited particles, pooled hit/VFX objects where profiling proves useful, two fighters max, simple gradients/shapes placeholder. Monitor average FPS/1% lows, memory usage and input response. First targets: 60 FPS simulation on lower-end reference Android and integrated-GPU Windows; binary target <150 MB (not guaranteed). Capture baseline metrics on actual devices before marking optimization done.
