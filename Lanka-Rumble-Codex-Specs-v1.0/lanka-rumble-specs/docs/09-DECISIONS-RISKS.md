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
