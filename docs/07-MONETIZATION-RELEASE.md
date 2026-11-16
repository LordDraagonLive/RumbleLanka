# 07 — Monetization, Distribution, Privacy and Rights

## 1. Platform-specific model

- Android: free download, all five fighters/stages playable, optional rewarded ads for cosmetic items or extra Arcade continues. Optional one-time remove-ads purchase. No progression paywall or stats boosts. Avoid interstitials in MVP; if added later, only at natural menu/results breaks, never during fight.
- Windows: paid game, launch pricing hypothesis USD $1.99–$3.99, all content, **no ad SDK** or store billing required in game (platform store handles purchase). Price and regional pricing not finalized.
- No servers, subscriptions, loot boxes or online analytics in MVP. Game offline if user declines ads.

## 2. Interface design

`MonetizationProvider` interface or base script methods: `is_ad_free() -> bool`, `is_rewarded_available() -> bool`, `request_rewarded(reward_id)`, `restore_purchases()`, signals `reward_granted(reward_id)` and `purchase_state_changed`. `NullMonetizationProvider` for editor/Windows that returns no ads and ad-free true. Android provider added in Phase 4 and must be behind feature flags. The game may not silently award ad rewards on callback failure. Offer a no-ad path to unlock gameplay-affecting Arcade continues through normal play; rewarded cosmetics allowed.

## 3. Release pipeline

Windows: export x64 package, test on Win 10 and 11; package with correct icon, credits, license notices and gamepad directions. Android: signed `.aab` for Play distribution (APK debug for internal testing), current target SDK policy at release, Play Billing/ads SDK compatibility, Store listing, privacy/ads disclosure, testers and crash QA. Ad removal purchase must restore after reinstall via store, and must not depend solely on editable local save.

## 4. Rights and content

User reports five individuals approved likeness/faces, profanity and have recorded MP3s. This is **an unverified but actionable project assumption for development**. Before publication, retain per-person scope, authorization evidence, whether permission covers commercial worldwide use, Android/Windows, promotion, duration, derivative caricature and voice performances; whether any third-party producers/studios own recordings, music or performances. Photograph/video owners may differ from depicted people. The historical king cannot provide permission; artworks/music/modern portrayals still may be protected.

Copyright-sensitive items: existing film quotes, music/lyrics, TV interviews, network logos, archival photos, sample beats, commercial song melodies, TikTok clip sound. Prefer original recorded dialogue that does not reproduce a third-party script or song without appropriate rights. Any line originating in a movie/song and recorded again may still require script/composition permissions.

## 5. Rating and store rules

Contains cartoon fighting and potentially explicit profanity. A clean toggle doesn't remove the explicit content from the shipped binary. Complete age rating questionnaires honestly, check target-region content policies, potentially restrict minors, and seek local legal review if commercial viability warrants it. Avoid real-world defamation or hateful abuse. This is a publishing readiness checkpoint, **not a restriction on developing the prototype**.

## 6. Data and privacy

Initial local save only, no logins or personal identifiers. Android ad and billing SDKs may process data; produce an accurate privacy policy/data safety declaration based on actual SDK behavior, including third-party consent requirements and region-specific regulations. Don't add ads SDK until privacy assessment.

## 7. Store readiness gate

All core QA passes, no crash on device lifecycle, ad removal restore verified, ads not in combat, pricing approved, rights status recorded and release-cleared, age rating completed, asset attribution/license manifests generated, English/Sinhala UI proofread, audio levels controlled, store metadata/test tracks approved. No automated store publishing without explicit developer instruction.
