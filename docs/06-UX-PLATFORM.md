# 06 — UX, Controls, and Platform Behaviour

## 1. Navigation

Splash (skip within 1s) -> Main Menu [Quick Fight, Arcade, Versus (Windows), Training, Fighters/Move List, Settings, Exit (Windows)] -> Fighter Select -> Stage Select -> VS card -> match -> Results [Rematch, Character Select, Menu; Next for Arcade]. Gamepad and keyboard navigate all menus; Android touch buttons have >=44 logical point equivalent interactive targets after scaling (validate device layout).

## 2. Default controls

| Meaning | Windows P1 | Windows P2 (proposed) | Android |
|--|--|--|--|
| Left/right | A/D | Left/Right arrows | D-pad horizontal |
| Jump/crouch | W/S | Up/Down arrows | D-pad vertical |
| Light | J | Num1 | L |
| Heavy | K | Num2 | H |
| Special | L | Num3 | S |
| Block | I | Num5 | B |
| Throw | J+K | Num1+Num2 | L+H |
| Super | K+L | Num2+Num3 | H+S |
| Pause | Esc | Enter | Pause UI |

Gamepads: sensible standard mapping discovered during integration (D-pad/left stick, face buttons/shoulders) and displayed in in-game controls panel; don't hardcode platform-specific button labels on all controllers. Limit accidental chord misfires with 3-frame combination window. Two-player device allocation and keys must be changeable or at minimum documented.

## 3. Android landscape touch HUD

Left lower zone D-pad (not fixed joystick; 4-direction held sectors); right lower zone 4 buttons diamond H-top, L-left, S-right, B-bottom; pause top-right, HP/timer top. Multi-touch capture supports direction plus two action buttons simultaneously, and fingers sliding between direction sectors. No touch button touches/covers the central fighters' hit/hurt UI area by default. Button opacity ~0.55, with press feedback, baseline target diameter ~52–72 dp where practical. Adapt to system cutouts and safe insets. Revalidate at 16:9, 18:9, 19.5:9, 20:9; maintain **fixed 16:9 combat viewport** and place touch overlays in safe screen coordinates, including side bars as usable UI when available.

## 4. Battle HUD

Top-left P1 health plus meter bottom-left, top-right P2 health plus meter bottom-right, timer top-center, round win pips under names. At round begin display Round N / Fight; on KO large KO; on draw Draw; after match show winner and rematch/next. For mobile provide uncluttered portrait-ish character cards only in select screens, not over match area. Avoid UI elements over fighter ground plane.

## 5. Pause and lifecycle

Windows Esc pauses; Android on background/app focus loss pauses and mutes transient effects. On resume require user to press Resume before accepting combat input; clear held input state and buffered chords to prevent accidental attacks. Audio interruptions and Bluetooth controller disconnect must not crash game. Game should restore settings and completed Arcade progression on restart; in-progress fight restore not promised.

## 6. Settings

Language en/si; dialogue profanity clean/beep/full; master/music/SFX/voice sliders; fullscreen/windowed desktop; screen shake low/off; hit flash toggle; Android touch opacity/size presets; control legend and controls remapping optional Phase 3. Default beep mode, moderate music volume, language auto-detect only if fallback verified, otherwise English.

## 7. Visual style

640x360 low-res pixel-art render, nearest neighbour sprites, one 16:9 arena view with pillarbox/letterbox for fairness; dynamic UI should remain crisp on high-DPI and readable in Sinhala. Caricatures are funny with slapstick effects and no blood/gore. Intro/KO visual effects max ~2s to retain pace.

## 8. Accessibility and safety

Subtitles on by default, color-independent meter and HP labeling, pause anytime outside disallowed intro transitions, avoid rapid repeated flashes or provide flash reduction, adjustable sound, configurable profanity, content disclosure on first launch. Avoid ads in matches and misleading reward prompts. Check age rating according to actually included uncensored assets, regardless of user's setting.
