# myMic — Technical Interview Prep

*First-person talking points for interviews about how you built myMic. Use this to answer “walk me through the technical side” without reading slides.*

---

## 30-second technical pitch

“I built **myMic** with **Flutter**, so one Dart codebase targets **iOS and Android**. The app has three speaking modes: **My Voice** for prompt-and-record practice, **Let’s Chat** with an AI buddy, and **Quick Debate** for short opinion practice. I integrated the **microphone**, **speech-to-text**, and **text-to-speech** on the device, and used **Google’s Gemini API** for conversational replies. I also handled **release engineering** — signing, App Store metadata, privacy disclosures, and shipping build **1.0.0** to Apple review.”

---

## 2-minute version (if they say “go deeper”)

“I structured the app with **go_router** and a bottom navigation shell: Home, Chat, and Debate. **My Voice** is a separate screen for low-pressure recording against rotating prompts.

For **Let’s Chat**, the flow is: user speaks → **speech_to_text** → text goes to a **Gemini chat session** with history and a custom system prompt for the buddy persona → reply is spoken with **flutter_tts**.

For **Quick Debate**, the user picks agree/disagree, speaks their argument, and Gemini returns a multi-sentence playful rebuttal — I added validation so replies aren’t too short.

**My Voice** can also send the **audio file** to Gemini when we want a faithful echo-back of what they said, not a rewrite.

I managed the **API key** through `--dart-define` and a local env file that never gets committed. On the release side, I generated icons and splash screens, built signed **IPA** and **AAB** artifacts, wrote a **privacy policy** that honestly states voice and text go to Google, and submitted to the **App Store**.”

---

## Likely questions & how to answer

### “Why Flutter instead of native iOS/Android or React Native?”

**Answer:** “I wanted **one codebase** for iPhone and Android while I was learning and shipping quickly. Flutter gave me fast UI iteration, good plugin support for **mic, STT, and TTS**, and a single release pipeline. The tradeoff is native edge cases — like iOS release validation — but for a v1 speaking app, Flutter was the right speed-to-ship choice.”

---

### “Walk me through the architecture.”

**Answer:** “It’s a fairly classic **feature-based layout**:

- **`lib/screens/`** — Home, My Voice, Talk (chat), Debate
- **`lib/services/`** — Gemini chat, debate one-shots, buddy audio echo, TTS, permissions
- **`lib/widgets/`** — recording controls, mascot, chat panels
- **`lib/routes.dart`** — **GoRouter** with a **ShellRoute** so the bottom nav persists

State is mostly **local to screens** plus **Provider** where shared. I deliberately kept it simple — no heavy architecture — because the complexity is in **audio permissions** and **AI session flow**, not in app-wide state.”

**If they want one level deeper:** “Chat uses a **persistent Gemini ChatSession** with seeded opening history so the model matches what the UI already showed. Debate uses **one-shot generateContent** with stricter prompts and a retry if the model returns something too short.”

---

### “How does the AI integration work technically?”

**Answer:** “I use Google’s **`google_generative_ai`** Dart package. The default model is **`gemini-2.5-flash`** — fast and good enough for short conversational turns.

- **Chat:** `GenerativeModel` + `startChat()` with **system instruction** (buddy persona in `spark_ai_prompt.dart`) and **message history**
- **Debate:** single prompt with topic, stance, and transcript; optional **repair prompt** if output fails length checks
- **My Voice / Buddy Says:** **audio bytes** attached to the request so Gemini transcribes and returns a **faithful repeat** line for TTS

The API key resolves in order: **`--dart-define`**, then bundled env for local dev, then process env. Production-minded approach is define-at-build-time; I know **client-side keys are a risk** and I’d move to a **backend proxy** in v2.”

---

### “What data leaves the device? That sounds like a privacy issue.”

**Answer:** “Yes — and I was explicit about it. **Voice recordings and message text are sent to Google Gemini** for the features to work. There are **no user accounts** and we don’t sell data, but it still counts as collection under Apple’s rules.

I aligned three things:
1. **In-app behavior** (what actually gets sent)
2. **Privacy policy** on our GitHub Pages site
3. **App Store App Privacy** questionnaire — Audio Data and Other User Content, purpose **App Functionality**, not tracking, not linked to identity

That honesty matters more than claiming ‘nothing leaves the phone’ when it does.”

---

### “How did you handle microphone and speech on mobile?”

**Answer:** “Three layers:

1. **Permissions** — `permission_handler` for mic (and speech recognition where needed)
2. **Capture** — `record` / `flutter_sound` for **My Voice** recordings (e.g. m4a)
3. **STT / TTS** — `speech_to_text` for live chat input, `flutter_tts` for buddy voice output, `just_audio` where we play files back

The tricky part isn’t the API calls — it’s **testing on real devices**, handling **permission denials gracefully**, and tuning TTS rate/pitch so it feels friendly not robotic.”

---

### “What was the hardest technical problem you hit?”

**Pick 1–2 of these — they’re true and interview-friendly:**

**1. App Store upload rejection (simulator binary in IPA)**  
“After testing on the **iOS Simulator** for screenshots, my release **IPA** failed Transporter validation: an **`objective_c.framework`** slice was built for **simulator**, not device. I diagnosed it by inspecting the IPA, did a **full `flutter clean`**, pinned **`path_provider_foundation`** to avoid the broken native-assets path, and rebuilt. Build **4** uploaded cleanly.”

**2. iPhone-only vs iPad screenshots**  
“Xcode targeted **iPhone + iPad**, so App Store Connect demanded iPad screenshots. I changed **`TARGETED_DEVICE_FAMILY`** to **iPhone only** and shipped a new build — simpler than generating iPad assets for v1.”

**3. API key security**  
“A key was accidentally at risk of being committed; I **rotated the key**, kept **`assets/default.env` empty in git**, used **skip-worktree** locally, and documented **`--dart-define`** for releases.”

**4. Repositioning without rewriting the whole app**  
“We shifted from a narrow ADHD/kids positioning to **general speaking confidence**. Technically that was mostly **copy, privacy policy, and store metadata** — good lesson that product and compliance are part of ‘engineering’.”

---

### “How did you ship to the App Store?”

**Answer:** “End-to-end I owned:

- **Apple Developer Program** (parent as account owner — I’m under 18)
- **Signed release IPA** via `flutter build ipa --release`
- **Transporter** upload; build processing in App Store Connect
- **Assets** — custom icon, splash, **1242×2688** screenshots (resized from simulator captures)
- **Metadata** — description, keywords, support URL, privacy URL
- **Compliance** — export encryption flag in Info.plist, age rating, App Privacy publish
- Submitted for **App Review**

On Android I also built a signed **`app-release.aab`** with a **JKS keystore** outside the repo and `key.properties` gitignored.”

---

### “What would you improve if you had more time?”

**Strong answers (shows maturity):**

1. **Backend for Gemini** — hide API key, add rate limits and logging
2. **On-device STT** — send **text** to Gemini, not raw audio, where possible
3. **Tests** — widget/integration tests for permission and recording flows
4. **Offline mode** — clear UX when network or API fails
5. **Localization** — strings + TTS language packs
6. **CI/CD** — automated builds, no manual Transporter uploads

---

### “What did you personally do vs what was automated / guided?”

**Honest framing:** “I wrote and iterated the **Flutter app**, integrated **Gemini**, configured **iOS/Android signing**, built **release artifacts**, created the **website/privacy policy**, prepared **store listing**, and debugged **upload blockers**. I used **AI-assisted development tools** (like Cursor) to move faster, but I made the **product, architecture, and release decisions** and validated behavior on **real devices**.”

---

## Technical vocabulary (quick reference)

| Term | What you mean in myMic |
|------|-------------------------|
| **Flutter / Dart** | Cross-platform UI framework |
| **GoRouter** | Declarative routes + shell navigation |
| **Gemini** | Google’s LLM API for chat/debate/audio |
| **STT** | Speech-to-text (`speech_to_text`) |
| **TTS** | Text-to-speech (`flutter_tts`) |
| **IPA / AAB** | iOS / Android store upload packages |
| **Bundle ID** | `com.mymic.mymic` |
| **App Privacy** | Apple’s data collection questionnaire |
| **`--dart-define`** | Compile-time env for secrets |
| **Transporter** | Mac app to upload IPA to Apple |

---

## Numbers you can cite (if asked)

| Item | Value |
|------|--------|
| Main screens | 4 (Home, My Voice, Chat, Debate) |
| Gemini model | `gemini-2.5-flash` |
| App version shipped | `1.0.0` (build 4 on iOS) |
| iOS deployment target | 13.0 |
| Android min SDK | 21 |
| Repo structure | ~28 Dart files under `lib/` |

---

## Questions to ask *them* (optional — shows product thinking)

- “Would you keep Gemini client-side for v1 or require a backend from day one?”
- “How would you structure on-device vs cloud speech processing?”
- “What’s your approach to child-safety and data minimization for voice apps?”

---

## What *not* to oversell

- Don’t claim **all processing is on-device** — audio/text go to Google for AI features.
- Don’t claim **enterprise-grade security** — v1 uses client API key.
- Don’t claim **large-scale architecture** — it’s a focused v1 with intentional simplicity.

---

## One-line closers (by interview type)

**College / internship:**  
“I shipped a real cross-platform app, integrated voice and AI, and learned that **release engineering and privacy** are as important as writing features.”

**Technical internship:**  
“I can walk you through the **recording → STT → Gemini → TTS** pipeline and the **iOS release failures** I debugged from logs and IPA inspection.”

**General:**  
“I built something people can actually download — not just a demo — and I can explain every layer from UI to App Store compliance.”

---

*Plain-language overview for non-technical audiences: [HOW_WE_BUILT_MYMIC_SHORT.md](./HOW_WE_BUILT_MYMIC_SHORT.md)*
