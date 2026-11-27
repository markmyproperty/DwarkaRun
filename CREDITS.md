# Credits

Every asset in Odyssey of the Ages (formerly Dwarka Run) is either original or properly licensed. This file lists them all.

## Art pack: "Dwarka Run: India / Ancient Dwarka"

The images in `assets/images/` come from the project's own Dwarka Run art pack, supplied by the project owner in two parts: monuments and buildings, then props, river and backgrounds. The pack's notes describe all 45 images as original work in a pastel clay-3D style, with no people, text, logos or watermarks. They were resized and converted to WebP for the game, and nothing else was changed.

| Folder | Images | Used in this version |
| --- | --- | --- |
| `monuments/` | 10 | City gateway over the path; temples, shrines, fort and palace as a distant backdrop only |
| `buildings/` | 6 | Shop-houses lining the Ayodhya Run street |
| `props/` | 15 | Obstacles: clay pot, stone debris, wooden crate, broken pillar. Kerb decoration: torch, marigold pot, golden vase, stone pillar |
| `backgrounds/` | 6 | Ayodhya: sky, temple hills and skyline. Ganga: the sunrise river backdrop. Hub postcards |
| `river/` | 8 | Ganga Run: ghat steps, boats on the water, rocks, pillars, floating diyas (decoration), the splash when you fall in |

Licence: owned by the project (the owner supplied it for this game). If any part was made with a third-party tool or under another licence, record it here.

Temples, shrines, the temple bell and the sacred lamp are never used as obstacles. They appear only in the background or beside the path.

## Stage art packs: Thar Desert Run (stage 03 desert pack), Himalayan Run, Vijayanagar Run

Supplied by the project owner as one zip per stage (stage 03, 04 and 05), in the same pastel clay-3D style. The packs' notes describe every image as original, with no people, text, logos or watermarks, no deity figures, empty shrine niches, and blank prayer flags. They live in `assets/images/<stage>/`, resized and converted to WebP. Horizon strips were trimmed of their side padding so they tile; nothing else was changed.

| Stage | Obstacles (props only) | Backdrop only |
| --- | --- | --- |
| Thar Desert Run | stone blocks, spike trap, sand pit, collapsing tiles, broken column, rolling boulder, swinging-blade doorway | pyramids, sphinx, obelisk, temples, tomb, houses, palms and dunes |
| Himalayan Run | snow mound, cracked ice, falling rocks, snowy crate, snow boulder, icicles under an ice ledge | monasteries, gompa, stupa, gates, prayer hall, houses, pines; prayer-flag poles and lanterns on the kerb |
| Vijayanagar Run | bazaar pot, rubble, leaning palace pillar, fallen lintel, ox cart, granite boulder, granite lintel on columns, monkeys | gopuram, palace, stone chariot, mandapa, stepped tank, stables, houses and boulders |

Licence: owned by the project, as for the first pack. Temples, shrines, stupas, the stone chariot and the sacred relics are never obstacles. The guardians and relics in these packs are kept for the guardian chases and relic hunt in a later version.

## Lanka Run art pack (stage 07)

Supplied by the project owner, same style and terms. The pack's notes say it is a palace-and-fortress stage with no deities or sacred figures, empty niches, and lotus only as ornament. In `assets/images/lanka/`.

- Obstacles: golden block, garden pot, flaming arrows between golden columns (slide), the fortress blade trap, a collapsing turret pillar and the closing palace gate.
- Backdrop only: golden palace, tower, citadel, pavilion, terrace, courtyard, palace stairs, water palace and fortress bridge, island houses, palms and gardens. Braziers are palace lights on the kerb.
- Kept for later: the palace sentinel guardian, the sun-jewel relic and the treasure chest.

## Stage art packs: Dwarka: The Sunken Kingdom (stage 09) and The Final Legend (stage 10)

Supplied by the project owner, same style and terms. The packs' notes describe them as mythology-inspired fantasy, not a claim about historical or archaeological Dwarka, with no deities, idols or sacred figures, empty doors and niches, and relics that are royal jewels, not religious icons. In `assets/images/sunken/` and `assets/images/finale/`.

- Sunken Kingdom obstacles: sea urchin coral, a pearl pile, drifting jellyfish (slide), coral block, collapsing coral column, the closing sea gate and a drifting whirlpool. Backdrop only: submerged palaces, coral tower, citadel, pavilion, cave hall, tunnel, whirlpool basin and coral bridge.
- Final Legend obstacles: golden cube, sea urchin coral, golden lanterns on a gilded beam (slide), collapsing golden column, falling gold masonry and the closing golden gate. Backdrop only: the golden city palace, spire, gate, terrace, sun court, treasury vault, relic chamber and the underwater palace, gateway and colonnade. The ceremonial urn is kerb decoration only.
- Kept for later: both sea guardians, both relics, the chests and treasure.

## Logo

`assets/images/brand/logo.webp`, the Android, iOS and web app icons: the "Odyssey of the Ages" logo, supplied by the project owner. Resized only (corners rounded for Android and the web).

## Hero run cycle

`assets/images/hero/run_01` to `run_16`: a 16-frame run cycle of an original crowned king, supplied by the project owner. Its notes say it was modelled, rigged and rendered from scratch in Blender 4.2 (GPL; rendered images carry no licence restriction), with no third-party model, rig, animation or texture. Cropped and converted to WebP. The code-drawn traveller remains as the stand-in while the frames load.

## Code-drawn art

These parts are original and drawn in code by this project, with no image files:

| Asset | Where it lives | Licence |
| --- | --- | --- |
| Hero (the young traveller), wings of light | `lib/game/track_painter.dart` | Original, part of this project |
| Fallback scenery for stages without art yet: banyan trees, bushes, stone ruins, wayside shrine | `lib/game/track_painter.dart` | Original, part of this project |
| Obstacles: fallen pillar, low branch, rolling millstone, rope barrier, fire pit, market cart, garland beam, ghat steps, hanging lanterns, monkey |
| River surfaces: floating planks, boats, bridge deck and railings | `lib/game/track_painter.dart` | Original, part of this project | `lib/game/track_painter.dart` | Original, part of this project |
| Pickups: mudra coin, gem, Garuda feather, Lotus charm | `lib/game/track_painter.dart`, `lib/presentation/pickup_icons.dart` | Original, part of this project |
| Hub postcard art for realms without a pack backdrop | `lib/presentation/realm_postcard.dart` | Original, part of this project |
| Stand-ins drawn while the art pack loads | `lib/game/track_painter.dart` | Original, part of this project |

## Icons and fonts

- Material Icons: Apache License 2.0, Google. Bundled with Flutter.
- Roboto (default Flutter font): Apache License 2.0, Google.

## Audio

Background music, supplied by the project owner (re-encoded to 128 kbps MP3 for the app):

| Stage | File | Source upload |
|---|---|---|
| Ayodhya Run | `assets/audio/ayodhya_run.mp3` | `ayodharun.mp3` |
| Ganga Run | `assets/audio/ganga_run.mp3` | `gangarun.mp3` |

Playback uses the [audioplayers](https://pub.dev/packages/audioplayers) package (MIT). Sound effects are not recorded yet.

## Code libraries

- [Flutter](https://flutter.dev): BSD 3-Clause
- [Flame](https://pub.dev/packages/flame): MIT
- [shared_preferences](https://pub.dev/packages/shared_preferences): BSD 3-Clause
- [intl](https://pub.dev/packages/intl): BSD 3-Clause
