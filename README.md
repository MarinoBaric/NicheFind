<div align="center">

<img src="https://img.shields.io/badge/NicheFind-6C4EE3?style=for-the-badge&labelColor=1a1a1a" alt="NicheFind" />

# NicheFind

**An AI-powered niche discovery tool for creators who haven't picked a direction yet.**

*Answer five questions. Get five niches you can actually work with.*

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?style=flat-square&logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-supported-black?style=flat-square&logo=apple&logoColor=white)
![Android](https://img.shields.io/badge/Android-supported-3DDC84?style=flat-square&logo=android&logoColor=white)
![DeepSeek](https://img.shields.io/badge/DeepSeek-API-1E3A8A?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-22C55E?style=flat-square)
![Status](https://img.shields.io/badge/status-active-F59E0B?style=flat-square)

[Wiki](../../wiki) · [Issues](../../issues) · [Roadmap](../../wiki/Roadmap) · [FAQ](../../wiki/FAQ)

</div>

<br/>

## About

NicheFind is a Flutter mobile app that helps people escape the "staring at a blank page" phase of starting something new, whether that's a YouTube channel, an online shop, a blog, or a side project. Instead of dumping the user into a blank text box, the app walks them through a short guided questionnaire and uses the DeepSeek API (backed by a second real-data source) to surface concrete, situation-specific niche ideas with reasoning, demand estimates, and first-step suggestions.

The app isn't trying to replace market research or write a business plan. It's trying to cut the "where do I even start" phase from weeks to about a minute.

> Built as the Project Four submission for ISTE 252 (Web and Mobile Computing) at RIT Croatia, Spring 2026.
>
> Competitive landscape write-up: [`NicheFind/docs/competitive-analysis.md`](./NicheFind/docs/competitive-analysis.md)

<br/>

## Why this exists

Before settling on a format that worked for my own YouTube Shorts channel, I spent weeks cycling through Reddit threads and "how to pick your niche" videos that all said the same five things. The tools available today fall into two uncomfortable extremes:

| Option | Why it falls short |
| :-- | :-- |
| General chatbots (ChatGPT, Claude, Gemini) | Require the user to already be a decent prompt engineer. Outputs drift generic without steering. |
| Paid research platforms (Ahrefs, Semrush, TubeBuddy) | Expensive, keyword-focused, designed for people who already know their lane. |

There's a gap between those two. NicheFind tries to fill it with something small, focused, and opinionated.

<br/>

## Features

- **Guided questionnaire.** Five quick steps using chips and preset cards, no intimidating blank text box.
- **DeepSeek-powered suggestions.** Structured output with reasoning, not wall-of-text advice.
- **Real-data grounding.** A second API attaches real metrics (YouTube result counts, recent upload frequency) to each niche, so the output isn't purely LLM fluff.
- **Regenerate and Refine.** Don't like the first batch? Get a fresh set, or steer them with presets like "more beginner-friendly" or "physical products only".
- **Native device integration.** Share, open in browser, copy, and offline-aware, via Flutter plugins.
- **Zero database by design.** No accounts, no tracking, no persistence beyond optional local form caching.

<br/>

## Screenshots

<div align="center">

<table>
  <tr>
    <td align="center"><b>Welcome</b></td>
    <td align="center"><b>Interests</b></td>
    <td align="center"><b>Goal</b></td>
    <td align="center"><b>Results</b></td>
  </tr>
  <tr>
    <td><i>screenshot</i></td>
    <td><i>screenshot</i></td>
    <td><i>screenshot</i></td>
    <td><i>screenshot</i></td>
  </tr>
</table>

<sub>Screenshots will replace the placeholders once the app build is final.</sub>

</div>

<br/>

## Tech stack

| Layer | Choice | Reason |
| :-- | :-- | :-- |
| Framework | Flutter (Dart 3.6) | Cross-platform, form-friendly widget set, one UI for iOS and Android |
| State | `provider` | Small state surface, no need for heavier tooling |
| HTTP | `http` | Simple, enough for two API calls |
| Formatting | `flutter_markdown` | Renders any markdown that slips through from DeepSeek |
| Native features | `share_plus`, `url_launcher`, `shared_preferences`, `connectivity_plus` | Share, open on YouTube, persist form state, detect offline |
| AI | DeepSeek API (`deepseek-chat`) | Cheaper per token than OpenAI, comparable quality on structured prompts |
| Secondary data | YouTube Data API v3 | Real result counts and upload frequency as a demand signal |

<br/>

## Getting started

### Prerequisites

- Flutter 3.x on the stable channel
- Xcode (for iOS) or Android Studio
- A DeepSeek API key from [platform.deepseek.com](https://platform.deepseek.com)
- A YouTube Data API v3 key from Google Cloud Console

Verify your Flutter install with `flutter doctor -v` before anything else.

### Clone and install

```bash
git clone https://github.com/<your-username>/NicheFind.git
cd NicheFind
flutter pub get
```

### Run locally

API keys are injected at build time via `--dart-define`, never committed to the repo.

```bash
flutter run \
  --dart-define=DEEPSEEK_API_KEY=sk-your-deepseek-key \
  --dart-define=YOUTUBE_API_KEY=AIzaSy-your-youtube-key
```

If you want to avoid pasting the keys every time, keep a gitignored `run.sh`:

```bash
#!/usr/bin/env bash
flutter run \
  --dart-define=DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY" \
  --dart-define=YOUTUBE_API_KEY="$YOUTUBE_API_KEY"
```

### Build a release

```bash
# Android
flutter build apk --release --dart-define=DEEPSEEK_API_KEY=... --dart-define=YOUTUBE_API_KEY=...

# iOS
flutter build ipa --release --dart-define=DEEPSEEK_API_KEY=... --dart-define=YOUTUBE_API_KEY=...
```

### Run tests

```bash
flutter test
```

<br/>

## Project structure

```
lib/
├── main.dart                       App root, theme, Provider setup
│
├── config/
│   └── api_config.dart             API keys (via --dart-define) and endpoints
│
├── models/
│   ├── questionnaire_data.dart     Form state model
│   └── niche_suggestion.dart       Parsed niche result
│
├── providers/
│   └── questionnaire_provider.dart ChangeNotifier holding form and results
│
├── services/
│   ├── deepseek_service.dart       HTTP client and response parser
│   ├── prompt_builder.dart         Turns form data into a structured prompt
│   └── youtube_service.dart        Secondary data source
│
├── screens/
│   ├── welcome_screen.dart
│   ├── interests_screen.dart
│   ├── goal_screen.dart
│   ├── skill_level_screen.dart
│   ├── time_commitment_screen.dart
│   ├── extra_notes_screen.dart
│   ├── loading_screen.dart
│   └── results_screen.dart
│
└── widgets/
    ├── step_indicator.dart
    ├── interest_chip.dart
    ├── niche_card.dart
    ├── refine_bottom_sheet.dart
    └── navigation_buttons.dart
```

Full architectural notes, including the data flow diagram and the error model, live on the [Architecture](../../wiki/Architecture) wiki page.

<br/>

## How it works

```
   form answers      structured prompt         raw JSON         parsed niches
  ───────────── ▶  ──────────────── ▶  ────────────── ▶  ───────────────── ▶  UI
  Provider           PromptBuilder         DeepSeek API       NicheParser
```

1. The user fills out five short questionnaire steps. Answers are held in a `QuestionnaireProvider`.
2. On Generate, `PromptBuilder` assembles a system + user message pair that includes the user's interests, goal, skill level, time commitment, and any free-text notes.
3. `DeepSeekService` sends the request over HTTPS with a 30-second timeout.
4. A tolerant parser handles three cases: clean JSON, fenced JSON, or a markdown fallback. On total failure the UI shows a retry state rather than surfacing raw errors.
5. Each parsed niche is enriched with a real metric from YouTube Data API. If the YouTube call fails, the niche still renders with a placeholder metric. The secondary API never blocks the main flow.
6. Results render as scrollable cards with Regenerate and Refine actions.

Prompt design notes and the iteration log live under [Prompt Engineering](../../wiki/Prompt-Engineering).

<br/>

## Design decisions

A few choices that will probably get asked about:

**No backend.** The DeepSeek key sits in a `String.fromEnvironment('DEEPSEEK_API_KEY')` constant read at build time. In production, the key belongs on a server. For a single-user class demo, hosting a server and a key vault just to hide a key would be scaffolding that adds nothing to the submission. A backend proxy is the first post-submission upgrade.

**No database.** Every session is a fresh API call. The only local persistence is an optional cache of the last-used form answers via `shared_preferences`, so a crash or reopen doesn't wipe progress. No accounts, no analytics, no telemetry.

**Two APIs, not one.** The original proposal leaned on DeepSeek alone. Professor feedback noted that a single API wasn't enough, and the fix genuinely makes the product better: LLM output is grounded in real YouTube data rather than presented as fact on its own authority.

**Flutter plugins over generic web wrappers.** The project brief mentioned Cordova plugins. Cordova is a different framework (hybrid web apps). In Flutter the equivalent concept is Flutter plugins from pub.dev, and the app uses four of them: `share_plus`, `url_launcher`, `shared_preferences`, and `connectivity_plus`. Each is tied to an actual user-facing feature, not just imported for the checkbox.

**Only five suggestions.** Enough to pick from, few enough to actually read. Long lists of LLM-generated ideas tend to let the generic ones drag down the good ones.

<br/>

## Roadmap

| Week | Dates | Focus |
| :-: | :-- | :-- |
| 1 | Apr 12, Apr 18 | Scope lock, wireframes, first API calls |
| 2 | Apr 19, Apr 25 | Core build, questionnaire wired end to end |
| 3 | Apr 26, May 2 | Error handling, polish, usability testing with classmates |
| 4 | May 3, May 12 | Iterate on testing notes, finalize, package submission |

Full milestone breakdown with checkboxes on the [Roadmap](../../wiki/Roadmap) wiki page.

<br/>

## Success metrics

Three buckets, because "it works" is too vague to evaluate.

- **Usability.** A first-time tester reaches their first set of niche suggestions within 30 seconds of opening the app, with no explanation from the author.
- **Output quality.** Niches feel specific. "Mobility routines for desk workers in their 30s" passes, "start a fitness blog" doesn't. A prompt iteration log tracks whether changes actually improve specificity.
- **Reliability.** The app does not crash, hang, or dump raw JSON on the user when the API misbehaves. Offline, 4xx, 5xx, and parse failures all have dedicated UI with retry.

<br/>

## Deliverables

The submission package includes:

- Initial sketches and Figma wireframes for the full flow
- The working Flutter prototype (source plus a release APK)
- Usability testing notes from the Week 3 sessions
- A before/after document showing what changed between the first build and the final one
- Saved examples of DeepSeek responses, both useful and not, to show how the prompt evolved
- A short written reflection on what worked and what I'd build next

Everything is organized by week so the progression is easy to follow.

<br/>

## Contributing

This is a coursework project, so external PRs aren't being accepted during the grading window. If you spot a bug or have an idea, opening an issue is welcome and I'll get to it after May 12.

<br/>

## Acknowledgments

- DeepSeek for making capable models affordable enough for a student project
- Classmates who agreed to be usability testers
- RIT Croatia, ISTE 252, Spring 2026

<br/>

## License

MIT. See [LICENSE](../LICENSE) for details.

<br/>

<div align="center">

<sub>Built with Flutter and DeepSeek. Maintained by <a href="https://github.com/">Marino Barić</a>.</sub>

</div>
