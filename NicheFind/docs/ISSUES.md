# NicheFind — GitHub Issues

Copy each block below into a new GitHub issue. Suggested labels and milestones
are noted at the top of each issue. Professor-feedback items are tagged
`feedback` and should be closed before final submission.

Suggested milestones:
- `Week 1 — Planning & API spike` (Apr 12 – Apr 18)
- `Week 2 — Wireframes & core build` (Apr 19 – Apr 25)
- `Week 3 — Polish, error handling, usability testing` (Apr 26 – May 2)
- `Week 4 — Analysis, iteration, final submission` (May 3 – May 12)

Suggested labels: `feedback`, `feature`, `bug`, `ux`, `docs`, `infra`,
`testing`, `research`, `good first issue`, `priority:high`, `priority:medium`,
`priority:low`.

---

## Professor feedback (must-fix before final)

### #1 Competitive analysis: review of similar niche-discovery apps
**Labels:** `feedback`, `research`, `docs`, `priority:high`
**Milestone:** Week 1

**Context**
Professor feedback explicitly called out the missing review of similar apps in
the proposal. Before iterating on NicheFind, we need a written comparison so
design decisions can point to something concrete.

**Scope**
Produce `docs/competitive-analysis.md` that covers at least 5 comparable
products, for example:
- General-purpose chat tools used for the same job: ChatGPT, Claude, Gemini
- Paid keyword/niche research tools: Ahrefs, Semrush, TubeBuddy, VidIQ
- Niche-idea generators: NicheLab, Exploding Topics, Answer the Public
- Any indie apps in the App Store / Play Store under "niche finder",
  "business idea generator", etc.

For each entry capture: what it does, who it's for, pricing, what it does well,
where it falls short, and how NicheFind is different.

**Acceptance criteria**
- [ ] At least 5 competitors documented with the fields above
- [ ] Short "positioning" paragraph at the end explaining NicheFind's gap
- [ ] Referenced from `README.md`
- [ ] At least 2 screenshots of competitor flows for comparison

---

### #2 Add a second data source / API (professor feedback)
**Labels:** `feedback`, `feature`, `priority:high`
**Milestone:** Week 2

**Context**
Professor feedback: "just one API is not enough". We need a second external
data source so niche suggestions aren't purely LLM-generated. The second API
should ground or validate DeepSeek's output with something measurable.

**Candidate APIs (pick one, justify in PR)**
- **YouTube Data API v3** — search a niche term, return video count,
  subscriber averages, and recent upload frequency to estimate
  competition/demand. Fits the YouTube Shorts use case exactly.
- **Reddit API (public JSON)** — count posts/subscribers in related
  subreddits to gauge audience interest.
- **Google Trends (via SerpAPI or a pytrends-style proxy)** — trend score
  over the last 12 months.
- **Wikipedia pageviews API** — free, no key, rough popularity signal.

**Scope**
- Add a new service under `lib/services/` for the chosen API.
- For each niche returned by DeepSeek, fetch 1–2 real metrics (e.g. "YouTube:
  12k results, avg 4 new videos/day") and attach them to the niche card.
- Add the API key (if needed) to `lib/config/api_config.dart` with a clear
  comment matching the existing DeepSeek key pattern.

**Acceptance criteria**
- [ ] Niche cards on the results screen show at least one data point from the
      second API
- [ ] Failure of the second API does not break the main flow (suggestions
      still render, metric shows "—")
- [ ] Choice of API is justified in the PR description
- [ ] `README.md` documents the second API and how to get a key

---

### #3 Use native device capabilities (Flutter plugins)
**Labels:** `feedback`, `feature`, `priority:high`
**Milestone:** Week 3

**Context**
Professor feedback mentioned Cordova plugins. NicheFind is a Flutter app, so
the equivalent is Flutter plugins that expose native device capabilities. We
should use at least 2–3 of them so the app isn't pure UI.

**Scope — add at least 3 of the following**
- `share_plus` — share a niche suggestion as text (Shortcut on the niche card)
- `url_launcher` — "Search this on YouTube / Google" button per niche
- `clipboard` (built-in) — copy niche text with a toast confirmation
- `shared_preferences` — remember the last set of answers so users don't have
  to refill the form after a crash
- `connectivity_plus` — detect no-internet state and show a proper empty
  state instead of a raw network error
- `path_provider` + `share_plus` — export results as a `.md` or `.txt` file
- `flutter_local_notifications` — optional, stretch: remind the user to
  revisit a saved niche

**Acceptance criteria**
- [ ] At least 3 plugins integrated and visible in `pubspec.yaml`
- [ ] Each plugin tied to an actual user-facing feature, not just imported
- [ ] Works on iOS (primary target per proposal)
- [ ] Permissions documented in `README.md` if any are required

---

## Core functionality (from proposal, not yet implemented)

### #4 Wire Generate button → DeepSeek → results screen
**Labels:** `feature`, `priority:high`
**Milestone:** Week 2

**Scope**
The skeleton has `DeepSeekService` and `PromptBuilder`, but they aren't yet
connected to the Generate button on the extra-notes screen. Complete the flow:
1. On Generate, collect all `QuestionnaireData` from the provider.
2. Build the prompt via `PromptBuilder`.
3. Call `DeepSeekService`, show `LoadingScreen` while waiting.
4. Parse the response into `NicheSuggestion` models.
5. Push `ResultsScreen`.

**Acceptance criteria**
- [ ] End-to-end run on a real device returns 3–5 niche cards
- [ ] Loading screen shown for the full duration of the call
- [ ] Parsing is tolerant to small format drift (missing fields don't crash)

---

### #5 Robust JSON / markdown parsing from DeepSeek
**Labels:** `feature`, `bug`, `priority:high`
**Milestone:** Week 2

**Context**
LLMs sometimes wrap JSON in ```json fences, add preamble text, or drop fields.
We need a parser that is tolerant to these variations.

**Scope**
- Strip code fences before parsing.
- If JSON parse fails, fall back to a markdown parser that reads
  `## heading / description / demand / competition / first steps` blocks.
- Log the raw response somewhere (debug only) so we can iterate on the prompt.

**Acceptance criteria**
- [ ] 10 sample responses in `docs/samples/` all parse to valid
      `NicheSuggestion` lists
- [ ] Parser unit tests cover: clean JSON, fenced JSON, trailing commentary,
      missing `demand` field

---

### #6 Regenerate button
**Labels:** `feature`, `priority:medium`
**Milestone:** Week 3

**Scope**
On the results screen, tapping **Regenerate** re-sends the same prompt with
a small instruction to produce different suggestions than the last batch.
Include a `previousResults` hint in the system prompt so the LLM doesn't
return the same niches.

**Acceptance criteria**
- [ ] Tapping Regenerate shows the loading state and then replaces the list
- [ ] New list has no identical titles to the previous list
- [ ] User can regenerate at least 3 times without hitting a client-side error

---

### #7 Refine button and refine sheet
**Labels:** `feature`, `priority:medium`
**Milestone:** Week 3

**Context**
`refine_bottom_sheet.dart` exists as a skeleton. Implement the flow:
- User taps Refine, sees a bottom sheet with presets ("more beginner-friendly",
  "focus on physical products", "lower competition", "under $100 to start")
  plus a free-text field.
- Selected refinements are appended to the prompt and re-sent.

**Acceptance criteria**
- [ ] At least 4 preset chips + custom text field
- [ ] Selections are visible on the results screen ("Refined: beginner-friendly")
- [ ] Clearing refinements is possible

---

### #8 Error states, retry, and offline handling
**Labels:** `feature`, `ux`, `priority:high`
**Milestone:** Week 3

**Scope**
Cover all the ways the API call can fail:
- No internet → offline illustration + Retry
- 4xx from DeepSeek → "Something's off with the request" + Retry
- 5xx or timeout → "DeepSeek is having a moment" + Retry
- Parse failure → "We got a response we couldn't read" + Retry + Send feedback

No raw JSON or stack traces should ever reach the user.

**Acceptance criteria**
- [ ] All four error states have dedicated UI
- [ ] Retry button works without requiring the user to refill the form
- [ ] Airplane mode test: app shows the offline state within 3 seconds

---

### #9 Loading state polish
**Labels:** `ux`, `priority:medium`
**Milestone:** Week 3

**Scope**
The loading screen currently exists but is minimal. Add:
- A short rotating caption ("Looking at your interests…", "Weighing
  competition…", "Finding gaps…") so 5–10 seconds of waiting feels deliberate.
- A subtle progress shimmer or animated illustration.
- A cancel affordance that returns to the form.

---

### #10 Form validation and back-navigation state
**Labels:** `feature`, `ux`, `priority:medium`
**Milestone:** Week 2

**Scope**
- Disable Next until minimum answers are provided on each step
  (at least 1 interest, a selected goal, a selected skill level, a
  time commitment).
- When the user taps Back, previously entered answers must still be there
  (state is already in the provider, just verify).
- Step indicator should not allow skipping ahead.

**Acceptance criteria**
- [ ] Next is disabled with a helper message when required fields are empty
- [ ] Back → Next preserves all answers on every step
- [ ] Custom interest entry is validated (no empty, no duplicates)

---

### #11 Prompt engineering iteration log
**Labels:** `research`, `docs`, `priority:medium`
**Milestone:** Week 1 → Week 4 (ongoing)

**Context**
Success metric from the proposal: niches should feel specific, not generic.
The proposal also commits to keeping a short log of good/bad outputs.

**Scope**
- Create `docs/prompt-log.md` with sections for each prompt version.
- For each version record: the exact prompt, 2–3 good outputs, 2–3 bad outputs,
  and what changed in the next iteration.
- Aim for at least 3 prompt iterations logged by final submission.

---

## UX and polish

### #12 App icon, splash screen, and name on home screen
**Labels:** `ux`, `priority:low`
**Milestone:** Week 4

**Scope**
- Design or generate a simple icon that matches the wireframes (sparkle mark).
- Use `flutter_launcher_icons` to generate iOS + Android icons.
- Add a splash screen via `flutter_native_splash`.

---

### #13 Dark mode support
**Labels:** `ux`, `priority:low`
**Milestone:** Week 4 (stretch)

**Scope**
- Define a dark `ThemeData` matching the purple accent.
- Wire to `MediaQuery.platformBrightnessOf(context)`.
- Verify all screens in both modes.

---

### #14 Accessibility pass
**Labels:** `ux`, `priority:medium`
**Milestone:** Week 3

**Scope**
- All tappable targets ≥ 44×44.
- Semantics labels on icon-only buttons (Regenerate, Refine, Share).
- Dynamic type: app should not overflow at the largest iOS text size.
- Color contrast checked on the chips and niche cards.

---

## Testing

### #15 Usability testing sessions (3–4 classmates)
**Labels:** `testing`, `research`, `priority:high`
**Milestone:** Week 3

**Scope**
- Build a test script (same scenario for every tester).
- Run 3–4 sessions, observe silently, take notes on where testers stall.
- Consolidate into `docs/usability-notes.md` with findings and 3–4 prioritized
  fixes to apply in Week 4.

**Acceptance criteria**
- [ ] 3 sessions completed
- [ ] Notes checked in
- [ ] 3 issues opened for the top usability problems

---

### #16 Unit tests for prompt builder and parser
**Labels:** `testing`, `priority:medium`
**Milestone:** Week 3

**Scope**
- `test/prompt_builder_test.dart`: verify that different questionnaire inputs
  produce the expected prompt structure.
- `test/niche_parser_test.dart`: cover JSON, fenced JSON, and markdown
  fallback paths from issue #5.

---

### #17 Widget smoke tests for each screen
**Labels:** `testing`, `priority:low`
**Milestone:** Week 4

**Scope**
- One `testWidgets` per screen that verifies the main elements render and
  Next/Back navigate correctly.

---

## Infrastructure and release

### #18 Replace hardcoded DeepSeek key with `--dart-define` for local runs
**Labels:** `infra`, `priority:medium`
**Milestone:** Week 2

**Context**
The proposal acknowledges the hardcoded key is a trade-off. At minimum, move
it to `String.fromEnvironment('DEEPSEEK_API_KEY')` with a placeholder default,
so the key isn't committed to the repo. Add a note in `README.md` showing
`flutter run --dart-define=DEEPSEEK_API_KEY=...`.

**Acceptance criteria**
- [ ] No real key in git history on `main`
- [ ] `README.md` has a "Running locally" section with the command

---

### #19 Build and attach a release iOS/Android artifact
**Labels:** `infra`, `priority:medium`
**Milestone:** Week 4

**Scope**
- Build a release APK (`flutter build apk --release`).
- Optionally build an iOS archive if signing is available.
- Attach the APK to the final GitHub release / submission bundle.

---

### #20 README with setup, run, and submission info
**Labels:** `docs`, `priority:high`
**Milestone:** Week 4

**Scope**
`README.md` should cover:
- What NicheFind is (one paragraph)
- Screenshots from the results screen
- Running locally (Flutter version, `--dart-define` command)
- Getting API keys (DeepSeek + second API from #2)
- Project structure
- Link to `docs/competitive-analysis.md`, `docs/prompt-log.md`,
  `docs/usability-notes.md`
- Credits and license

---

### #21 Before/after deliverable document
**Labels:** `docs`, `priority:medium`
**Milestone:** Week 4

**Scope**
`docs/before-after.md` — side-by-side of the first working build vs the final
submission. Include screenshots, list of changes, and short rationale for each.
Required by the proposal's deliverables section.

---

### #22 Save and include example DeepSeek responses
**Labels:** `docs`, `priority:low`
**Milestone:** Week 4

**Scope**
Collect 5 good and 3 bad responses into `docs/samples/` as `.md` files. Referenced by
the prompt-log (issue #11) and required by the proposal's deliverables.

---

### #23 Short written reflection
**Labels:** `docs`, `priority:medium`
**Milestone:** Week 4

**Scope**
`docs/reflection.md` — one page: what worked, what didn't, what I'd build next
if I continued. Required by the proposal's deliverables section.
