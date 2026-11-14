# Lanka Rumble — Implementation Specification Pack v1.0

**Date:** 2026-11-14  
**Status:** Ready for vertical-slice implementation; content and commercial release clearance remain separate gates.  
**Project:** 2D Sri Lankan meme arcade fighting game, Android + Windows first.

## Read in order

1. `AGENTS.md` — Codex agent rules and first task.
2. `docs/01-PRODUCT-REQUIREMENTS.md` — scope, modes, platforms, acceptance.
3. `docs/02-GAMEPLAY-COMBAT.md` — normative mechanical specification.
4. `docs/03-FIGHTERS-CONTENT.md` — roster, moves, character bible.
5. `docs/04-TECHNICAL-ARCHITECTURE.md` — Godot systems/scenes/contracts.
6. `docs/05-DATA-ASSETS-AUDIO.md` — data models, audio placeholder pipeline, localization.
7. `docs/06-UX-PLATFORM.md` — menus, input, mobile layout, accessibility.
8. `docs/07-MONETIZATION-RELEASE.md` — Android ads and Windows paid build.
9. `docs/08-BACKLOG-TEST-PLAN.md` — epics, tasks, milestones and QA.
10. `docs/09-DECISIONS-RISKS.md` — decisions, assumptions and unresolved details.
11. `prompts/START-CODEX.md` — copy-paste first Codex implementation prompt.

## Fixed decisions

- Godot **4.7.2 stable**, **GDScript**, **Compatibility** renderer.
- Landscape 2D pixel caricature arcade fighting; **60 Hz combat simulation**.
- 5 launch fighters: Rajangane Saddharathana Thero (Rajangane Hamuduruwo), Ranjan Ramanayake, Lasith Malinga, Sri Vikrama Rajasinha (last king of Kandy), Chamara Ranawaka.
- 4 action buttons L/H/S/B plus direction combinations; keyboard, gamepad, Android touch.
- Android free + optional rewarded ads / ad-removal; Windows low-cost paid, no ads.
- Sinhala/English only, original voice sessions exist but **use placeholders until imported**.
- Cartoon/slapstick violence. Uncensored Sinhala profanity supported with clean/censored variants, subject to age rating and store policies.
- MVP: 5 fighters, 3 stages, arcade, quick fight, local Windows versus, CPU, training, local settings/progress. **No online multiplayer**.

## Important sequencing

**Phase 0:** bootable Godot project -> **Phase 1:** two-placeholder-fighter Windows vertical slice -> **Phase 2:** Android touch export -> **Phase 3:** 5-fighter content -> **Phase 4:** monetization and store readiness.

Do not require voice MP3s, finished caricatures, ads SDKs, Apple tooling, or external accounts for the first playable build. Never attribute fabricated dialogue to a real person; keep `source_status` fields. Implement input, combat, content, and monetization behind clean interfaces.

## Local environment

Primary development: Windows 10/11, PowerShell, Git, Godot editor, Android Studio SDK, OpenJDK 17. Secondary: Linux with the same Godot project. Windows + Android exports are the initial shipping targets. iOS requires macOS/Xcode/signing later.

## Source references

- Godot release archive: https://godotengine.org/download/archive/
- Godot Android export: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Godot resolutions/pixel art: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
- Godot audio formats: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio_samples.html

This pack contains **specification and Codex instructions**, not a completed game or actual voice recordings.
