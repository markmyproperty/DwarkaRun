# Credits

Every asset in Dwarka Run is either original or properly licensed. This file lists them all.

## Art pack: "Dwarka Run: India / Ancient Dwarka"

The images in `assets/images/` come from the project's own Dwarka Run art pack, supplied by the project owner in two parts: monuments and buildings, then props, river and backgrounds. The pack's notes describe all 45 images as original work in a pastel clay-3D style, with no people, text, logos or watermarks. They were resized and converted to WebP for the game, and nothing else was changed.

| Folder | Images | Used in this version |
| --- | --- | --- |
| `monuments/` | 10 | City gateway over the path; temples, fort and palace as a distant backdrop only |
| `buildings/` | 6 | Shop-houses lining the Ayodhya Run street |
| `props/` | 15 | Obstacles: clay pot, stone debris, wooden crate, broken pillar. Kerb decoration: torch, marigold pot, golden vase, stone pillar |
| `backgrounds/` | 6 | Sky, temple hills and Dwarka skyline behind the city; hub postcard |
| `river/` | 8 | Kept for Ganga Run (stage 2) |

Licence: owned by the project (the owner supplied it for this game). If any part was made with a third-party tool or under another licence, record it here.

Temples, shrines, the temple bell and the sacred lamp are never used as obstacles. They appear only in the background or beside the path.

## Code-drawn art

These parts are original and drawn in code by this project, with no image files:

| Asset | Where it lives | Licence |
| --- | --- | --- |
| Hero (the young traveller), wings of light | `lib/game/track_painter.dart` | Original, part of this project |
| Fallback scenery for stages without art yet: banyan trees, bushes, stone ruins, wayside shrine | `lib/game/track_painter.dart` | Original, part of this project |
| Obstacles: fallen pillar, low branch, rolling millstone, rope barrier, fire pit, market cart, garland beam, monkey | `lib/game/track_painter.dart` | Original, part of this project |
| Pickups: mudra coin, gem, Garuda feather, Lotus charm | `lib/game/track_painter.dart`, `lib/presentation/pickup_icons.dart` | Original, part of this project |
| Hub postcard art for realms without a pack backdrop | `lib/presentation/realm_postcard.dart` | Original, part of this project |
| Stand-ins drawn while the art pack loads | `lib/game/track_painter.dart` | Original, part of this project |

## Icons and fonts

- Material Icons: Apache License 2.0, Google. Bundled with Flutter.
- Roboto (default Flutter font): Apache License 2.0, Google.

## Audio

No audio files yet. Sound effects and music per realm arrive in a later stage and will be listed here with their licences (original or CC0).

## Code libraries

- [Flutter](https://flutter.dev): BSD 3-Clause
- [Flame](https://pub.dev/packages/flame): MIT
- [shared_preferences](https://pub.dev/packages/shared_preferences): BSD 3-Clause
- [intl](https://pub.dev/packages/intl): BSD 3-Clause
