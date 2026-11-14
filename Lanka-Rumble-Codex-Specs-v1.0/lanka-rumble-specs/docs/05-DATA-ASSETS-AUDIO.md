# 05 — Data, Asset Manifest, Voice and Localization Contracts

## 1. Rules

No actual voice MP3s have been attached to this implementation pack. The user reports personally recorded authorized sessions with the people featured. **Do not wait for recordings**; every requested dialogue event produces optional text subtitle + placeholder audio (short generated beep/neutral blip or silence). Audio should be drop-in by ID. Never mimic a real person's voice via voice cloning. Do not auto-retrieve social media videos, show audio copyright ownership as verified, or conflate newly-written phrases with real quotes.

## 2. Canonical resource definitions

`FighterDefinition`: `id`, `display_name_key`, `portrait_path`, `sprites_path`, `health`, `walk_speed`, `jump_velocity`, `animations` (state->name), `attacks` (input key->AttackDefinition path), `dialogue_profile_id`, `ui_color`, `enabled`.

`AttackDefinition`: `id`, `input_action`, `startup_ticks`, `active_ticks`, `recovery_ticks`, `damage`, `hit_level`, `blockstun_ticks`, `hitstun_ticks`, `hitstop_ticks`, `chip_ratio`, `meter_gain_on_hit`, `movement_curve`, `hitbox_rects_per_tick` or hitbox phases, `strike_ids`, `hit_limit_per_target`, `projectile_data` optional, `armour_hits` optional, `invulnerable_to` optional, `cancel_routes`, `sound_event`, `vfx_event`, `dialogue_event` optional, `super_cost` optional. All timing integer ticks.

`StageDefinition`: `id`, `background_asset`, `floor_y`, `left_bound`, `right_bound`, `music_event`, `ambience_event`; bounds must match in MVP.

`DialogueEntry`: see `examples/dialogue.sample.json`. Localisation key to texts separate from path; MP3 filename mapped by ID. `source_status`: `original_game_dialogue`, `user_supplied_recording_unverified_transcript`, `verified_recording_transcript`, `fictional_historical_parody`. `rights_status`: `pending_record_import`, `permission_reported`, `cleared_for_release`, `requires_review`. Do not infer `cleared_for_release` from missing metadata. Clip permissions tracked per asset.

## 3. Media folders

```text
assets/audio/voice/si/<fighter_id>/<dialogue_id>.ogg
assets/audio/voice/en/<fighter_id>/<dialogue_id>.ogg
assets/audio/placeholders/voice_blip.wav
assets/audio/sfx/<event>.wav
assets/audio/music/<stage>.ogg
assets/fighters/<fighter_id>/portrait.png
assets/fighters/<fighter_id>/spritesheet.png
assets/stages/<stage_id>/background.png
assets/ui/fonts/<licensed_font>.ttf
```

A Godot project can import MP3, Ogg Vorbis and WAV. Preserve original MP3 source in an **external non-redistributed master directory**; optionally convert finished short dialogue to WAV or Ogg for runtime. Keep original recordings, session/legal notes and unreleased outtakes private and out of Git unless explicitly authorized. Use minimum gain normalisation, strip trailing silence, fade edges to avoid clicks, and test playback on both platforms.

## 4. Voice event dictionary

Shared: `intro.01`, `light.01`, `heavy.01`, `special_1.01`, `special_2.01`, `super.01`, `hit.01`, `ko.01`, `taunt.01`, `victory.01`. Fighter-specific IDs see fighter bible. Sound has cooldowns (no line spam every minor hit), probability weighting and prioritization (KO > super > special > hit > idle). No overlapping long speech by same character; queue or duck as appropriate. Any missing clip falls back to text + subtle SFX, no null dereference.

## 5. Profanity variants

Each explicit line may have `full`, `beep`, `clean` variants. The clean option requires a distinct alternate **audio** recording or silence + separate text, not only masking the text while playing uncensored audio. If no clean audio exists, display clean subtitles and play neutral blip/silence. `beep` can replace words using timestamped intervals only when supported by metadata; otherwise use alternate censored file or safe fallback. Mechanics and frame timings unchanged by selected variant. Player profile setting default: **beep** on first install to reduce surprise, but full mode fully supported; regardless of default, rate the distributed build for all contained material.

## 6. Text and language

Use translation keys, not hard-coded UI strings. Sinhala Unicode UTF-8; license an appropriate font that correctly renders complex Sinhala clusters in the Godot build. English fallback. Example keys: `ui.main.play`, `ui.quickfight.title`, `ui.settings.language`, `fighter.chamara.name`, `move.chamara.daruwa`, `dialogue.chamara.intro.daruwa`. For line subtitles, both English/Sinhala translations optional; if translation absent, show original language text and flag missing localization in QA.

## 7. Art pipeline

Original caricature sprites commissioned or generated with ownership recorded; stylized, exaggerated, not photorealistic. Target body ~96–160 px tall at 640x360 viewport; pivot center feet, sprite art may extend outside body hurtbox. Required states (initial): idle, walk, crouch, jump/fall, standing light/heavy, sweep, air attack, block, hit, knockdown, getup, specials 1&2, super, KO, victory, intro. Minimal prototype uses color-coded polygon bodies and geometric effects. Target spritesheet frame naming conventions and metadata atlas before mass asset production.

**Chamara photo references:** two user-provided screenshots from TV/interview show bald head, dark sunglasses, white shirt, metallic necklace. These are art **references**, not cleared photo sprites. Do not embed screenshots in distributable game or open repository unless image copyright cleared.

## 8. Asset QA gates

For each roster member: consistent feet pivot, facing mirrored correctly, animation state coverage or fallback, no missing resource paths, voice line trigger frequency cap, safe size/format, subtitle readability on 16:9 and 20:9, no accidental copyrighted music/TV clip usage, and source/rights status documented. Store all export-ready masters separately from test placeholders.
