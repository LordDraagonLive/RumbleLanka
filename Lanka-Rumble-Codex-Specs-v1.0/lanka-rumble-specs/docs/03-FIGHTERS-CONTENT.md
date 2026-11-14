# 03 — Fighter Bible, Signatures and Content

## General policy

These are **fictional exaggerated fighting-game depictions**. The user reports authorization for caricature likeness and profanity and has professionally recorded voice clips from the five people. We do not have the recorded audio in the project yet. Do **not** use third-party TV/music/video clips or invent biographical allegations. Distinguish `original_game_dialogue`, `user_supplied_recorded_dialogue`, and `verified_public_quote`; original lines are not represented as real historic utterances. Audio event IDs not actual filename assumptions.

Each character: normal move family, 2 special moves, one super, 3–6 taunt/intro/hit/win voice slots, 1–5 caricature silhouettes. Names and romanisation listed below are initial display keys, adjustable via localization. Caricatures should avoid reproducing copyrighted costumes or third-party artwork without clearance. Film references are contextual; visual action moves must be original.

## F01 — Ranjan Ramanayake (`ranjan`)

Archetype Balanced/action hero. HP 1000, walk ~175px/s. Stylised cinematic stage poses, punch/kick silhouette, heroic grin, theatrical finishes. Default intro: action-hero pose. Standard forward heavy is a dramatic kick, long startup/recovery.

- **Hero Uppercut**, `S`: 3-hit? No: **single** rising strike, startup 9, active 5, recovery 21, damage 105; strong anti-air, punishable on block.
- **Flying Hero Kick**, `F+S`: horizontal advancing jump-kick, startup 13, active 6, recovery 22, damage 120; can leap over low projectiles only during specified airborne frames; unsafe if blocked.
- **Cinema Climax / One Shot**, `H+S`: scripted two-hit action combo, total 280 raw damage before scaling, 100 meter. `One Shot` is an associated film/nickname reference, not copied soundtrack or film audio.
- Cosmetic dialogue slots: `ranjan.intro.malli`, `ranjan.taunt.yaaluwo`, `ranjan.special.one_shot`, `ranjan.victory.record_kara`, `ranjan.hit.01`. Candidate supplied phrases: “උන් ඔක්කොම යාළුවෝ මල්ලි”, “මල්ලි”, “මම රෙකෝඩ් කරා”, “වන් ෂොට්!”. Recordings/transcript verification pending import.

## F02 — Lasith Malinga (`malinga`)

Archetype ranged/zoning. HP 900, walk ~165. Exaggerated iconic curly highlighted hairstyle, cricket-inspired original attire and sling-bowling silhouette; no team logos without rights. Projectiles are oversized stylised balls, cartoon impacts.

- **Yorker Shot**, `S`: low travelling projectile, startup 17, damage 85, lifespan 100 ticks, max 2 active; must be crouch-blocked.
- **Sling Ball**, `F+S`: high parabolic projectile, startup 22, damage 90, travels above low attack path and falls toward opponent; mid hit level on contact; avoid unavoidable screen traps.
- **Four in Four**, `H+S`: four sequential cricket hit effects, max 4 strike IDs, total 260 raw damage, gaps permitting counterplay if first hit misses; consumes 100 meter.
- Dialogue slots: `malinga.intro.apewadak`, `malinga.taunt.wadakbalan`, `malinga.victory.01`, `malinga.super.fourinfour`. Supplied candidate “වැඩක් බලාගෙන යනවා මනුස්සයෝ යන්න!”, “අපේ වැඩක් අපිට කරගන්න දෙන්න”. Avoid assuming other supplied attributions are recorded verbatim.

## F03 — Sri Vikrama Rajasinha (`rajasinha`)

**Historical figure:** Last ruler of the Kingdom of Kandy, 1798–1815. Not to be confused with earlier Kings Rajasinha. Archetype heavyweight/counter; HP 1200, walk ~120. Visually comic royal clothing, crown and stylised ceremonial prop rather than historically factual fighting style. Do not claim comic folktales actually happened to this king.

- **Royal Guard**, `S`: 10-tick counter window from tick 5; counters a non-throw close-range strike for 115 damage, whiff recovery 22; no protection from projectiles unless later explicitly specified.
- **Royal Charge**, `F+S`: slow advancing impact, startup 17, active 8, recovery 24, damage 145; has one-hit armour during active advance, takes normal damage and ignores one stagger.
- **Royal Judgment**, `H+S`: original ceremonial shockwave, damage 300, mid, large warning animation, no decapitation/gore.
- Voice slots: `rajasinha.intro.bola`, `rajasinha.taunt.adikaram`, `rajasinha.special.charge`, `rajasinha.super.judgment`, `rajasinha.victory.01`. Candidate fictional stage-style lines “බොල!”, “මහා අදිකාරම්, මේ මොකද මේ වෙන්නේ?”, “හිස ගසා දමව්!”. All marked `fictional_historical_parody`, never verified historical quotes.

## F04 — Rajangane Saddharathana Thero / Rajangane Hamuduruwo (`rajangane`)

Archetype trickster/disruptor. HP 950, walk ~155. Exaggerated poses/speech bubbles/phone and beep motifs. The game parodies public online-performance styles, not faith or religious observance. No fabricated damaging claims.

- **Speech Burst**, `S`: short-range comic speech-wave projectile; startup 12, damage 75, medium blockstun; cap one active wave.
- **Dramatic Dash / Me Balapan**, `F+S`: forward feint with short invulnerability to projectile hitboxes only from frames 4–8, then 70-damage strike; startup 15, recovery 21; vulnerable to throws.
- **Nonstop Monologue / Beep Barrage**, `H+S`: multi-hit comic speech bubble wave, up to 5 unique strikes and 250 raw total damage; SFX can be uncensored or beeped while **identical mechanics** remain.
- Voice slots: `rajangane.intro.bayana`, `rajangane.taunt.warenko`, `rajangane.special.balapan`, `rajangane.hit.explicit_01`, `rajangane.victory.01`. Supplied candidate text “අඩෝ, මම බය නෑ යකෝ!”, “වරෙන්කෝ බලන්න!”, “මේ බලපන්!”. Explicit recorded lines to be transcribed from user-provided recordings, not made up and attributed as quotations.

## F05 — Chamara Ranawaka (`chamara`)

Archetype rhythm/rushdown/wildcard. HP 900, walk ~180. **Primary supplied photographic reference:** bald head, dark sunglasses, white T-shirt, chunky metal neck accessory, expressive gestures; use uploaded reference images privately for concept art, do not repackage original TV screenshots as production sprites. Sunglasses adjustment and necklace gesture as idle poses.

- **Hawa Giya Kade**, `S`: humorous animated umbrella prop launched short-medium range; startup 15, damage 85, mid, max one prop active; original artwork, not source interview video.
- **Munta Track / Track Step**, `F+S`: direction-feint advance then 2-hit rush, damage 45+55, startup 11; not random/unreactable; track step recovery 20.
- **Nonstop Baila**, `H+S`: choreographed rhythm combo, 5 unique strikes, raw total 265, 100 meter, original composition/foley only; no commercial song recordings or licensed melody used by default.
- **Daruwa!** uses `H` heavy animation callout (not an extra attack binding). **Mage Raththaran** is a victory/intro line; defensive buff `D+S` is *optional post-MVP* (do not implement extra buff until baseline balance works).
- Voice slots: `chamara.intro.daruwa`, `chamara.taunt.muntatrack`, `chamara.special.hawa`, `chamara.victory.adarei`, `chamara.ko.01`. Supplied candidate phrases: “දරුවා!”, “ආදරෙයි තෙරුවන් සරණයි”, “මගේ රත්තරං”, “ආදරෙයි අම්මට වගේ”, “හාවා ගියා කඩේ අරගෙන දිග කුඩේ”, “මුන්ට ට්‍රැක්”, “සතුට කියාගන්න බෑ”. Song lyric snippets are **not** cleared merely because likeness or voice was authorised; avoid lyric-based dialogue until separate rights verification.

## Shared animation contract (17 slots)

`idle`, `walk_forward`, `walk_back`, `crouch`, `jump`, `fall`, `light`, `heavy`, `crouch_light`, `sweep`, `air_attack`, `special_1`, `special_2`, `super`, `block`, `hit`, `ko`, plus optional `getup`, `victory`, `intro`. Minimal placeholder content may reuse sprites; do not gate state-machine implementation on animation availability. Animations are presentation, attack frames are authoritative. Prefer 8–15 visible FPS at 60 simulation ticks.

## Stage themes

1. `junction`: stylised roadside, bus/tuk-tuk silhouettes, no brand logos.
2. `station`: rail/bus-station-themed platform with animated background props, decorative only.
3. `royal_court`: fanciful Kandyan-inspired hall, respectful cultural art, not a literal historical reconstruction.

All stages share identical collision floor and boundaries in MVP. Distractions/crowds run without modifying fighter physics or collision.

## Character selection

Five cards in 3+2 grid; one disabled `coming soon` placeholder. Can choose mirror matches for quick fight/versus (same fighter twice) using independent state instances. Arcade opponents: every other fighter once, seeded shuffled; no boss fighter beyond roster at MVP.
