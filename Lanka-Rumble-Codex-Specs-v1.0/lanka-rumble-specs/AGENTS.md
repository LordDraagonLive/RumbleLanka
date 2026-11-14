# AGENTS.md — Lanka Rumble coding agent instructions

You are implementing a Godot 4.7.2 stable GDScript game according to the specifications in `docs/`. Read `README.md` and relevant docs before coding. If ambiguity exists, pick the smallest reversible implementation, note it in `docs/09-DECISIONS-RISKS.md`, and keep working; do not invent new scope.

## Non-negotiable rules

1. Produce a **runnable playable increment**, not architectural pseudocode. No non-existent addons or undocumented APIs.
2. Godot 4.7.2 + GDScript; 2D Compatibility renderer; 60 physics ticks/sec; no C# dependency or paid plugins.
3. First implement **two clearly labelled placeholder fighters**, generic stage, Windows keyboard, human vs human or AI. Integrate named personalities after combat works.
4. Always separate **combat simulation**, **input mapping**, **presentation**, **content Resource definitions**, and **monetization**.
5. Fighter states and hit resolution must be frame-based, testable and immune to accidental repeated hits in one attack instance.
6. Four buttons: L light, H heavy, S special, B block; L+H throw; H+S super (if meter ready); directional S variations. Resolve simultaneous-input precedence explicitly.
7. Support mirrored fighter facing, correct character-local front/back, hitstop, hitstun, blockstun, KO, stage boundaries, rounds, and timeouts.
8. Input devices must go through one action-frame interface; Android touch uses the same interface as Windows and AI.
9. Provide placeholder audio and sprite assets where real content does not exist. Never download real-person media or copyrighted audio automatically.
10. Do not state that permission is legally verified merely because user reports permission. Keep rights metadata, do not block prototype.
11. No ads, analytics, external network calls, logins or SDK requirement in the first vertical slice.
12. Use Git-friendly `.tres` resources and clear directories. Keep exported binaries and signing keys out of source control.
13. Add automated testable logic where feasible, a manual QA checklist, and a Windows smoke-build instruction for every milestone.
14. Maintain `CHANGELOG.md` and explain actual commands used to test; never claim export/device testing not performed.

## Work style

- Inspect existing files before modifications. Don't overwrite user assets.
- Implement one coherent milestone per change set, keep test/project startup working.
- Use meaningful GDScript types, signals and Resources; avoid giant global singleton scripts.
- Make character numeric balance data configurable; do not scatter hard-coded fighter IDs.
- Choose clear asset fallbacks (polygon bodies, simple gradients, generated UI) rather than stopping for artwork.
- For any unverified Godot API detail, consult installed engine help or official 4.7 docs.

## First milestone: VS-01

Implement `project.godot`, startup menu (Start Fight / Quit), stage, two placeholder `FighterController` actors, keyboard input P1/P2, facing, walk, jump, crouch, light/heavy attack with active/recovery timing, hitboxes and hurtboxes, block, hit reactions, health HUD, KO, 99-second clock, best-of-three rounds. Use simple visual placeholders. Then run headless import/script checks if the Godot executable exists and document results. **Do not implement all five full fighters in VS-01.**

See `prompts/START-CODEX.md` for task handoff.
