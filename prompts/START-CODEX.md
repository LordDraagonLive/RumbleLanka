# First Codex Task — Copy/Paste

Read `AGENTS.md`, `README.md`, `docs/01-PRODUCT-REQUIREMENTS.md`, `docs/02-GAMEPLAY-COMBAT.md`, `docs/04-TECHNICAL-ARCHITECTURE.md`, and `docs/08-BACKLOG-TEST-PLAN.md` in this repository.

**Implement only Phase 0 and Phase 1 / VS-01 first.** Build a runnable Godot 4.7.2 standard GDScript project (Compatibility renderer, 640x360 viewport, 60 fixed physics ticks) with:

1. Start Fight/Quit menu and one simple debug arena.
2. Two color-coded **placeholder** fighters (NOT copyrighted portraits), keyboard P1 WASD + J/K/L/I, P2 arrows + Num1/Num2/Num3/Num5 where available.
3. Facing, walk, jump, crouch, limited stage boundaries, two attacks (light/heavy), active startup/recovery frame data, visual hit/hurtboxes in debug.
4. Block, correct guard checks, HP HUD, 99-second timer, KO, best-of-three round flow.
5. Prevent multiple damage triggers from one strike. Simultaneous KO is draw. Fixed timestep, input and simulation separated, no voice asset dependency.
6. Minimal automated smoke tests for damage once per attack, block and round win; clear instructions for Windows editor run/export.
7. `CHANGELOG.md`, `.gitignore`, basic source file comments and report any Godot executable/test limitations.

Use primitive shapes as placeholder graphics. No ads SDK, actual voice recordings, advanced movesets, extra five roster characters, Android billing, online play or final brand art yet. Preserve maintainability and create proper `FighterDefinition` / `AttackDefinition` Resource abstractions early.

After implementation: list files, how to run locally, tests **actually executed**, limitations, and next VS-02 tasks. If an API is uncertain, check the installed engine or stable documentation instead of guessing.
