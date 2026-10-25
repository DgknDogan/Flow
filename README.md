# Flow

**Flow** is a personal finance app for iPhone, built with SwiftUI and the iOS 26 Liquid Glass design. You log your income and expenses, set a budget, and see where your money goes. A built-in AI assistant answers questions about your spending, and it runs entirely on your device.

![Platform](https://img.shields.io/badge/platform-iOS%2026.2%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)
![Languages](https://img.shields.io/badge/languages-6-34C759)

---

## Features

### Track every transaction
- Add income or expenses in a step-by-step form with a custom amount keypad.
- 12 expense categories (Housing, Groceries, Dining Out, Transportation, Subscriptions and more) and 9 income categories (Salary, Freelance, Investment, Bonus and more).
- Add an optional note to each transaction, and edit or swipe to delete it later.

### Home
- A day strip and a month picker for moving through your history.
- Search across all transactions.
- A collapsible header that snaps as you scroll.

### Details and reports
- Week, month and year views. You can step back through earlier periods and jump back to the current one with a single tap.
- Income, expense, net balance and transaction count.
- A spending chart with your daily or monthly average and your limit marked on it.
- Budget progress, plus a projection of where the period will end at your current pace.
- Insights: your busiest day or month, and a comparison with the previous period.
- Spending and income broken down by category, with a donut chart and a drill-down into each category.
- Your largest expenses for the period.
- **CSV export**: save the selected week, month or year to the Files app (UTF-8, ready for spreadsheets).

### On-device AI assistant
- Ask questions like *"How much did I spend on dining out last month?"*.
- Powered by **Gemma 4 E2B** running locally through [LiteRT-LM](https://github.com/john-rocky/swift-litert-lm). Your financial data never leaves your phone.
- The model calls a spending-summary tool, so its answers come from your real transactions instead of guesses.
- Saved conversation history.
- The model (about 2.6 GB) downloads once the first time you open the assistant.

### Budget and reminders
- A daily spending limit, with an alert when you pass a warning threshold you choose.
- Optional daily and weekly reminders to log your spending.

### Privacy and sync
- **App Lock** with Face ID or Touch ID.
- **iCloud sync** across your devices through CloudKit (optional).

### Personalization
- Light, dark or system appearance.
- 5 currencies: USD, EUR, GBP, TRY, CHF.
- 6 languages: English, Türkçe, Deutsch, Español, Français, Italiano. You can switch the language inside the app.
- A profile with a photo and statistics about your spending.

---

## Tech stack

| Area | Technology |
|---|---|
| UI | SwiftUI, Liquid Glass (`glassEffect`, `GlassEffectContainer`), Swift Charts |
| State | Observation (`@Observable`), MVVM |
| Persistence | SwiftData + CloudKit |
| AI | Gemma 4 E2B on [swift-litert-lm](https://github.com/john-rocky/swift-litert-lm), with tool calling |
| Security | LocalAuthentication (Face ID / Touch ID) |
| Notifications | UserNotifications |
| Localization | String Catalog (`Localizable.xcstrings`) |
| Concurrency | Swift 6 language mode, strict concurrency, `MainActor` default isolation |
| Testing | Swift Testing (unit), XCUITest with the Page Object pattern (UI) |

## Project structure

```
Flow/
├── App/            # Entry point, root view, navigation (router, tabs, routes)
├── Core/           # Shared components, design tokens, models, persistence, managers
└── Features/
    ├── Home/              # Transaction list, date strip, search
    ├── TransactionForm/   # Step-by-step add/edit form
    ├── Details/           # Period reports, charts, CSV export
    ├── Assistant/         # On-device Gemma assistant and its tools
    ├── Profile/           # Profile photo and statistics
    ├── Settings/          # Appearance, budget, currency, language, security, sync
    ├── Onboarding/        # First-launch introduction
    └── AppLock/           # Biometric lock screen
FlowTests/          # Unit tests (Swift Testing)
FlowUITests/        # UI tests (XCUITest, Page Objects)
```

## Getting started

### Requirements
- Xcode 26.2 or later
- iOS 26.2 or later (simulator or device)

### Run
1. Clone the repository:
   ```bash
   git clone https://github.com/DgknDogan/Flow.git
   ```
2. Open `Flow.xcodeproj` in Xcode. Swift Package Manager resolves the dependencies automatically.
3. Choose the **Flow** scheme and run it (`⌘R`).

> **Note:** iCloud sync and push notifications need your own Apple Developer team and iCloud container. To run on a device, change the bundle identifier and signing team in *Signing & Capabilities*.

> **Assistant:** the assistant runs on the simulator using the CPU, so answers are slow there. On a real device it uses the GPU.

### Tests
```bash
xcodebuild test -project Flow.xcodeproj -scheme Flow -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

UI tests start the app with launch arguments (`-ui-testing`, `-ui-testing-seed`, `-ui-testing-skip-onboarding`). These keep real data untouched by using an in-memory store and a separate defaults suite.

---

## Author

[@DgknDogan](https://github.com/DgknDogan)
