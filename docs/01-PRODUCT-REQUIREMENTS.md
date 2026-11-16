# 01 — Product Requirements Document (PRD)

## 1. Summary

**Lanka Rumble** (working title) is a funny, low-resource 2D 1v1 fighting game inspired by 1990s arcade titles, with exaggerated pixel-art caricatures of five Sri Lankan personalities. The game emphasizes accessible local play, distinct meme-themed specials and original Sinhala/English voice recordings. The user reports having recorded original MP3 clips with the individuals and approval for likeness/profanity; recordings are not supplied with this spec, so placeholders are mandatory for implementation.

## 2. Goals and success criteria

G1. A newcomer can complete a fight without tutorial in under five minutes. G2. Each fighter has visibly different mechanics and recognisable visual silhouette. G3. Core combat works offline on Windows and Android. G4. Low- or mid-range devices can maintain a target 60 FPS in a typical battle (validate empirically). G5. Adding fighter 6 should require new configuration/assets and minimal engine code. G6. Game can be monetized without ads during combat or player accounts.

Release gate: one continuous 20-match local QA session without crashes/softlocks on every official target device class, plus feature acceptance in doc 08. FPS and device requirements are *targets*, not proven claims.

## 3. Audience and rating

Sri Lankan audience plus diaspora, English- and Sinhala-speaking users, casual fighting game players. Contains cartoon violence and optionally uncensored adult Sinhala profanity; plan for mature audiences and review app-store age/content ratings. Do not market as a children's game.

## 4. Platform scope

| Platform | MVP | Notes |
|--|--|--|
| Windows 10/11 x64 | Must | Keyboard + standard controller(s), local 2P |
| Android | Must | Landscape touch, optional controller, APK tests/AAB release |
| Linux desktop | Later | Same codebase, CI smoke export |
| macOS | Later | Same codebase, packaging/signing |
| iOS | Later | macOS/Xcode, touch adaptation, signing |

No client-server backend required. Offline-first; only ads and entitlement restoration may need internet.

## 5. Core game modes

- **Quick Fight (MVP):** choose fighter, CPU opponent, stage, difficulty; press Fight.
- **Arcade (MVP):** choose character; fight 4 other roster members in seeded order, then victory; simple interstitial text only, no authored story campaign.
- **Local Versus (MVP Windows):** two local players on keyboard(s) and/or controllers. Two-player keyboard mapping must avoid conflicts, and default P2 uses arrows plus numpad keys, remappable.
- **Training (MVP minimal):** fixed dummy with optional AI, restart, unlimited HP/meter toggles, move list. Advanced frame analysis deferred.
- **Android PvP:** not required for MVP; controller-based local 2P may be supported opportunistically.
- **Online PvP:** expressly out of scope, including backend, matchmaking, rollback, network sync and anti-cheat.

## 6. Game content MVP

Five specified fighters; three launch stages (generic roadside/tuk-tuk junction, bus/rail stop, stylised Kandyan royal court; names/art provisional); up to 17 basic animation states/fighter depending on shared clips, 2 specials and 1 super each; intro/taunt/hit/KO/win voice event slots with placeholders; health, special meter, timer, round counters; local settings and progress. All three stages must use the same combat dimensions, with no gameplay-affecting hazards.

## 7. Match spec

Best of three rounds, 99 seconds each, 60 Hz physics ticks. A fighter wins by opponent KO or on timer by **higher percentage of max health** (not absolute raw HP, since starting HP differs). Equal remaining percentage -> **draw round** and restart round; after three consecutive draw rounds in the same matchup, next round is sudden-death (first valid hit wins), to guarantee eventual resolution with active players. On simultaneous KO, draw round. Arcade score/results recorded locally. No network clock.

## 8. Localization and accessibility

Sinhala and English menus/subtitles; default English UI until chosen; Sinhala voice default per fighter where available, optional English lines where recorded; subtitles can differ from speech only for translation/clean variants. Adjustable master/music/SFX/voice volumes; mute voice; profanity clean/beep/full setting; toggle shake/flash; large-touch-button presets and remapping later. On Android default layout must be playable on 16:9 through 20:9 landscape and respect display safe areas.

## 9. Monetization

Android free with optional rewarded ads, optional one-time ad-removal purchase; no pay-to-win, no forced mid-match ads. Windows low-cost paid (planning target USD $1.99–$3.99), no ad SDK. No monetization code or payment requirement for VS-01. Store copy must honestly state ad and mature content presence.

## 10. User flows

Launch -> Main Menu -> Quick Fight / Arcade / Versus / Training -> Character Select -> Stage Select (where relevant) -> VS intro -> Round(s) -> Results -> Rematch / Select / Menu.

For Arcade: Next Opponent route from results, save progress only after completed match. Back, Pause, Resume, Settings, Quit to Menu available; Android pause on app background. Audio placeholders still trigger and subtitles remain visible.

## 11. Out of scope

Online PvP, dedicated servers, user identity, cloud saving, leaderboards, accounts, lootboxes, battle passes, skins marketplace, 3D, real violent injury/gore, cinematic story mode, user-generated fighters, live ops. Avoid speculative 'AI dialogue' or scraped likenesses.

## 12. Definition of done

MVP only complete when all user stories and tests in `08-BACKLOG-TEST-PLAN.md` pass on Windows and Android, all referenced assets have valid fallback, game survives pause/resume, purchase states are correct in release builds, and rights/age/store checks are documented. Prototype development may proceed independently of final legal/commercial clearance.
