# 09 — Decision Log, Assumptions and Risks

## Confirmed by user

- Android + Windows first; future Linux/macOS/iOS.
- Five actual personalities named in fighter bible.
- Exaggerated caricature pixel graphics; 90s visual style; modest hardware.
- Sinhala + English only.
- Four buttons accepted with combos/direction; six-button fallback not needed now.
- Hybrid pricing: Android free/ad-supported with paid ad removal, Windows cheap paid.
- Original recorded MP3 clips of catchphrases incl profanity exist but will be integrated later. Use placeholders now.
- User reports approval to use five faces and profanity.
- Cartoon/slapstick violence and no high-end graphical requirement.

## Engineering defaults — adjustable after vertical slice

- Godot 4.7.2 stable, GDScript, Compatibility rendering.
- 640×360 16:9 fixed arena (letterboxing), 60 Hz.
- 1000-ish HP, 99s, best of three, meter reset each round, 100-meter supers.
- Four input buttons, 3-tick chord tolerance, 6-tick attack buffer.
- Three suggested stage themes, named in fighter bible.
- 5 fighter roster, 3 stages, arcade/quick fight/local Windows versus/training.
- Default profanity **beep** for first launch; player can choose full or clean.
- Arcade order seeded/random over other four, no final boss.
- Android no forced interstitials initial release; only optional rewarded ads and ad-removal.

## Important unverified facts / open decisions

- Commercial consent/voice/likeness authorization documents have **not** been independently verified; request/review before commercial ship. Specific exact contents of recordings not yet provided.
- Some provided phrases have unclear historical origin or quote authenticity; treat as user-supplied candidates, not verified transcripts until checked against recordings.
- Third-party rights for photographs, TV clips, movie dialogues, music and lyrics not automatically cleared by individual consent.
- Actual release publisher, Android package ID, store accounts, brand/logo, licence for Sinhala fonts, final price/currency, privacy policy, and final ratings all TBD.
- Hardware minimums, final FPS, game download size and final crash rates **must** be measured, not advertised prematurely.
- Android ad/billing provider and version-dependent plugin selection should be decided in Phase 4 against current store rules.
- Keyboard P2 defaults may conflict with some laptops lacking numpad; configure an alternative remap later.
- We have two user-provided Chamara screenshots as art references but not export-ready assets.

## Risks and mitigation

| Risk | Impact | Mitigation |
|--|--|--|
| Unverified rights/quote lineage | Store/legal | Provenance manifest, use original new dialogue, release clearance gate |
| Profanity/app rating | Eligibility/marketing | Three dialogue modes; accurate mature rating and store disclosures |
| Five unique sprites and supers overwhelm schedule | Delivery | Two generic fighters first, modular placeholder art |
| Mobile input chords feel awkward | Gameplay | 3-tick chord tolerance, mobile playtest, hold/tap UX |
| Different screen ratios affect hit range | Fairness | Fixed 16:9 arena + separate UI layer |
| Knockback/collision cause softlocks | Gameplay | Fixed-step resolver, state tests, debug overlay |
| Asset MP3 import variability | Crashes/audio | Placeholder fallback, asset validation, normalized formats |
| SDK/billing/Android requirements change | Release | Verify immediately before publishing |
| Different devices at 60 FPS | Performance | Compatibility renderer, profiling, targeted tests |
| AI impossible/challenge mismatch | Player retention | Same input system as human, per-difficulty reaction delay |

## Scope change policy

After VS-01 playtesting, changes to attacks/stats and art are cheap; changes to core modes or networking are explicitly new scope. Record meaningful changes and any decision override in this file with date and rationale.

## 2026-11-14 - Phase 0 / VS-01 implementation decisions

- The Godot project lives beside this specification pack's README and docs. Both fighters use generic names, 1000 HP and shared configurable normals, not the five named personalities.
- Use explicit synchronous Rect2 hit/hurt geometry instead of Area2D callbacks. Collect both contacts before applying results; each attack instance owns its victim registry. This implements doc 02's equivalent geometric model and permits headless tests.
- VS-06 calls for throw exceptions even though VS2-01 also mentions throws. Implement one minimal shared L+H grounded throw now, plus mid/low/overhead normals, so guards have testable exceptions. Keep character specials, projectiles, meter and supers for Phase 2. H+S falls back to heavy; S alone is reserved. B+attack is ignored.
- Three-tick chord collection delays initial attack selection by up to two ticks before frame 1 of startup. Recovery buffering expires after six simulation ticks; stun, getup, landing, KO and round transitions discard pending input. Hitstop freezes the simulation, including its input-buffer clock; device edges sampled during hitstop are not queued in this slice.
- Aerial normals clear their hitboxes on landing and apply Resource-defined 5/9 ticks of landing recovery. Basic jumps enter AIRBORNE immediately; authored jump-start/landing animation polish remains later work.
- Local input defaults remain in project.godot for editor configurability. P2 U/O/P alternatives complement the prescribed numpad defaults without conflicting with P1. Runtime remapping and real keyboard-rollover validation remain later work.
- Placeholder audio is an original silence Resource with visible captions. Silence is intentionally not sent to the audio driver; a presentation provider can later play supplied clips. No fabricated dialogue, real-person art, network calls, monetisation implementation or SDKs are included. Reference images are preserved, ignored by Godot and excluded from export.
- Godot 4.7.2 Standard and matching Windows templates were downloaded into an ignored workspace-local `.tools` folder for checks/export. Exported builds are ignored and reproducible through tools/build-windows.ps1. Original user assets were preserved. No repository was initialised and no commit was made because this workspace did not contain Git metadata or a Git executable.
- Automated Windows headless and rendered checks are evidence of implementation behavior, not completion of the two-human target-hardware exit gate or the 20-match release QA matrix. See docs/11-TEST-RESULTS.md for measured results and pending checks.

## 2026-11-16 - Throw input investigation

Physical-key reproduction verified the existing throw bindings and collision/damage rules. Keep the prescribed three-tick chord window and original short throw reach rather than changing balance to conceal control ambiguity. Replace on-screen L+H shorthand with actual keyboard combinations, label attempted throws, and show successful-throw captions. The new dedicated throw suite and live-scene tests cover the full input path. See docs/12-THROW-CHECK.md for actual results; human keyboard rollover remains unverified.

### Follow-up: confirmed staggered-key failure

The user confirmed P1 J+K produced a light/heavy punch. Reproducing key edges three to five ticks apart demonstrated the timing problem missed by the first investigation's same-tick/one-tick/two-tick cases. This supersedes the initial decision to retain strict keyboard timing. Default keyboard throw tolerance is now six ticks (approximately 100 ms), while initial normal selection stays at three ticks. Resource data explicitly permits converting the first grounded normal's startup into a throw when both buttons remain held and the second edge is within the original press's window. This never cancels an active/recovery frame, changes damage/reach, or restarts the window after a queued input. Canonical InputFrame defaults remain three ticks. The setting is reversible in project.godot. Tests prove both normal first-hit timings are unchanged. See docs/13-THROW-TIMING-FIX.md for before/after evidence.

## 2026-11-16 - Repository-root layout

At the user's request, move the implementation and retained specs out of `Lanka-Rumble-Codex-Specs-v1.0/lanka-rumble-specs` into the Git/workspace root. This supersedes the initial placement decision from 2026-11-14. Keep one project.godot and one source tree; all res:// paths and existing .uid sidecars stay unchanged. Move builds/QA artifacts into root builds/, merge ignore rules, and archive the former .godot/editor-created folders under ignored `.tools/migrations/root-layout-2026-11-16` before regenerating imports. All 106 source-file hashes matched immediately after relocation. Preserve original reference assets and historical evidence; historical reports retain their original command paths with migration notices. Current instructions use the root project. No gameplay or throw-animation changes belong to this refactor. See docs/14-PROJECT-STRUCTURE.md for actual verification.
