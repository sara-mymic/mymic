# How myMic Was Built — Short Version

*Created by Sara Han.*

*A plain-language overview for interviews, presentations, or anyone who asks: “How did you build this app?”*

---

## What is myMic?

**myMic** is a mobile app that helps people **practice speaking out loud** and build confidence. Users get short speaking prompts, a friendly AI chat buddy, and playful mini-debates — useful for language learners, conversation prep, or anyone who wants to feel more comfortable when they talk.

The app is published by **Sara Han** and is available on **iPhone** (submitted to the Apple App Store). An **Android** version was also built and prepared for Google Play.

---

## How it was built (the big picture)

1. **Chose a cross-platform tool** — I used **Flutter**, which lets one codebase run on both iPhone and Android.
2. **Designed three main experiences** in the app:
   - **My Voice** — read a prompt, record yourself speaking, hear it played back.
   - **Let’s Chat** — talk with a friendly character (“Buddy”) powered by AI.
   - **Quick Debate** — pick a fun topic, choose a side, and practice making your point.
3. **Added voice technology** — the app uses the phone’s **microphone**, **speech-to-text** (turning speech into words), and **text-to-speech** (the buddy “talks” back).
4. **Connected AI for conversation** — chat and debate replies use **Google’s Gemini** API so the buddy can respond naturally. Voice recordings and message text are sent to Google for processing (disclosed in our privacy policy).
5. **Built a simple public website** — landing page and privacy policy, hosted free on **GitHub Pages** (`mymic-site`).
6. **Prepared for release** — custom app icon and splash screen, store screenshots, App Store metadata, privacy questionnaire, signed builds, and upload via Apple’s **Transporter** app.

---

## Tools I used

| Area | What |
|------|------|
| App framework | Flutter (Dart) |
| AI | Google Gemini API |
| Voice | Device mic, speech-to-text, text-to-speech |
| Code & backup | GitHub (private repo) |
| Website | HTML/CSS on GitHub Pages |
| Apple release | Apple Developer Program, App Store Connect, Transporter |
| Android release | Google Play Console, signed App Bundle (`.aab`) |

---

## What I learned along the way

- **Store rules matter early** — privacy policy, age rating, and honest data disclosure (including that voice/text goes to Google) are required before launch.
- **Real devices beat simulators** — testing on physical phones caught issues the emulator missed.
- **Release builds are different** — signing keys, version numbers, icons, and SDK versions (e.g. Xcode updates) are separate steps from “it runs on my phone.”
- **Iteration is normal** — we repositioned the app from a narrow ADHD/kids focus to a **broader “speak with confidence”** audience, updated the website and store copy, and fixed blockers (icons, iPhone-only target, build errors) as they came up.

---

## One-sentence summary

*I built myMic with Flutter so one app runs on iPhone and Android, added microphone and AI-powered conversation features with Google Gemini, published a privacy policy and landing page, and shipped a signed build to the Apple App Store.*

---

*For high school presentations: [HOW_WE_BUILT_MYMIC_HIGH_SCHOOL.md](./HOW_WE_BUILT_MYMIC_HIGH_SCHOOL.md) · Interview prep: [HOW_WE_BUILT_MYMIC_DEVELOPER.md](./HOW_WE_BUILT_MYMIC_DEVELOPER.md)*
