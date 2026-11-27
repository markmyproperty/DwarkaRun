# Dwarka Run

An original, 3D-feel endless runner built with Flutter and Flame. A young traveller sets out on a quest through ten legendary worlds inspired by ancient India, other ancient civilisations and fantasy.

It runs on Android, iOS and the web from one codebase, with no backend. Progress is saved on the device.

## The ten stages

The order is final (see the master brief):

1. Ayodhya Run
2. Ganga Run
3. Pharaoh Run
4. Himalayan Run
5. Vijayanagar Run
6. Dragon Valley
7. Lanka Run
8. Indus Run
9. Dwarka: The Sunken Kingdom
10. Dwarka Run: The Final Legend

## Status

Each step lands as its own pull request.

| Step | What it adds | State |
| --- | --- | --- |
| 1 | Core run, Ayodhya Run (art pack part 1), the hub with all ten stages on the route, saving, English and Hindi | Done |
| 2 | Ganga Run (art pack part 2): ghats, a river crossing on boats and floating planks, and the bridge finale | This version |
| 3 | Relics, keys, missions, guardian chases and the shop | After that |
| 4+ | One stage per pull request, each built when its art pack arrives | Later |

## How to play

- Swipe left or right to change lanes, up to jump, down to slide.
- On a keyboard: arrow keys or WASD, space to boost, Esc or P to pause.
- Collect gold **mudra** coins and rare **gems**.
- A **Garuda feather** gives a boost charge: tap the feather button to fly over everything for a few seconds.
- A **Lotus charm** pulls nearby mudra towards you.
- Cheeky **monkeys** snatch a few mudra if you run into them. Jump over them.
- Run the stage's distance to cross it. A crash ends the run.
- In Ganga Run, the path gives way to open water: run along boats and floating planks, and jump the gaps or change lane. Falling in ends the run.

The very first run opens gently: slower, with one obstacle at a time and swipe hints.

## Run it

You need Flutter 3.50 or newer.

```sh
flutter pub get
flutter run                 # a connected phone or emulator
flutter run -d chrome       # the web
flutter test                # all tests
```

To watch a bot play on the web, add `?autopilot=1` to the URL.

## Builds

```sh
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release --no-web-resources-cdn
```

## How the code is laid out

```
assets/images/   art pack, resized WebP (see CREDITS.md)
lib/
  game/          Flame game, rules, seeded level generator, collisions, painting
  data/          progress repository (shared_preferences)
  presentation/  hub, run screen, HUD, pause, game over, realm complete
  audio/         sound interface with mute (sound files arrive in stage 3)
  analytics/     analytics interface with no-op and recording versions
  game/art_library.dart  loads the art pack in the background; code-drawn stand-ins until it is ready
  l10n/          ARB strings: English and Hindi, with Tamil, Bengali and Marathi files ready
```

- **Rules live in `RunSimulation`**, with no Flutter in it, so tests step it directly. It runs in fixed 1/120 s steps, so the same seed and input always play out the same.
- **Levels come from a seed** (`SeededRandom`, mulberry32), identical on every platform. Every row leaves at least one lane the hero can get through.
- **Painting is plain canvas calls**, projected by hand, far to near. Obstacles and coins come from fixed pools, and paints, paths and draw buffers are reused, so a frame allocates almost nothing.
- **Analytics events**: `game_open`, `run_start`, `run_end`, `realm_complete`, plus `site_bought` and `share_clicked` ready for stage 3.

## Accessibility

- Respects the system Reduce motion setting: no screen shake, no pulsing Play button, no spinning coins or bobbing.
- Every button has a semantic label and a tap target of at least 52 px.
- Pickups differ in shape as well as colour (round coin, diamond gem, long feather, petalled lotus).

## Respect for the source material

Dwarka Run draws on broad themes of ancient India. Deities never appear as obstacles or enemies, and are never hit or mocked. They may only appear as benevolent background presences, such as a wayside shrine. The hero is an original young traveller. No religious symbol is placed on anything that gets hit, smashed or stepped on.

All art, characters and names are original. See [CREDITS.md](CREDITS.md).
