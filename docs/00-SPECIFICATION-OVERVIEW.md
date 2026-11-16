# Lanka Rumble specification overview

The original **Lanka Rumble Implementation Specification Pack v1.0**, dated 2026-11-14, supplied the requirements for this project. Its documents, data examples, implementation prompt and art references are retained in the repository. The versioned extraction-directory wrapper was removed on 2026-11-16; the game now lives at the repository root, as the architecture intended.

The current runnable increment is Phase 0 and Phase 1 / VS-01. The full product targets below describe future delivery, not features already implemented. [The root README](../README.md) is the current entry point for launching and developing the game.

## Read in order

1. [AGENTS.md](../AGENTS.md) - development instructions and scope.
2. [Product requirements](01-PRODUCT-REQUIREMENTS.md).
3. [Normative gameplay and combat](02-GAMEPLAY-COMBAT.md).
4. [Fighters and content](03-FIGHTERS-CONTENT.md).
5. [Technical architecture](04-TECHNICAL-ARCHITECTURE.md).
6. [Data, assets and audio](05-DATA-ASSETS-AUDIO.md).
7. [UX and platforms](06-UX-PLATFORM.md).
8. [Monetisation and release](07-MONETIZATION-RELEASE.md).
9. [Backlog and test plan](08-BACKLOG-TEST-PLAN.md).
10. [Decisions and risks](09-DECISIONS-RISKS.md).
11. [Original implementation handoff](../prompts/START-CODEX.md).

## Product decisions from the pack

- Godot 4.7.2 Standard, GDScript, Compatibility renderer, 640x360 fixed combat viewport and 60 Hz simulation.
- Android and Windows first; later Linux/macOS/iOS remain possible. No online multiplayer or backend in MVP.
- Two generic placeholder fighters first. Full roster target: Rajangane Saddharathana Thero, Ranjan Ramanayake, Lasith Malinga, Sri Vikrama Rajasinha and Chamara Ranawaka.
- Four abstract action buttons (Light, Heavy, Special, Block), plus direction combinations, throw and super chords. All device adapters supply the same InputFrame contract.
- Full MVP target: five fighters, three stages, arcade, quick fight, local Windows versus, CPU, training and local settings/progress.
- Sinhala and English, with placeholder audio until recordings are supplied. Cartoon/slapstick violence; no fabricated real-person dialogue or scraped media.
- User-reported likeness/voice permission remains an unverified development assumption, not release clearance. Reference photographs are preserved separately from runtime art and excluded from export.
- Future Android free/optional rewarded ads and ad-removal; future Windows paid distribution. Monetisation and SDK integration are excluded from VS-01.

Sequencing remains **Phase 0 foundation -> Phase 1 Windows placeholder slice -> Phase 2 touch, combat extensions and Android -> Phase 3 roster/UX -> Phase 4 commercial readiness**. Original voice sessions, final art, ads, external accounts and store signing must not block prototype work.

Keep combat, input, presentation and content Resources separate. Test reports distinguish actual automated/export execution from pending human or device checks. See the [current structure and migration report](14-PROJECT-STRUCTURE.md) for repository ownership and paths.
