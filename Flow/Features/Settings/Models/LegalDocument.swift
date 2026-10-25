import SwiftUI

/// About ekranından açılan, uygulamanın içinde gösterilen yasal metinler.
enum LegalDocument: Hashable, CaseIterable {
    case terms
    case privacy
    case acknowledgements

    struct Section: Identifiable {
        let heading: LocalizedStringKey
        let body: LocalizedStringKey

        var id: String { "\(heading)" }
    }

    var title: LocalizedStringResource {
        switch self {
        case .terms: "Terms of Service"
        case .privacy: "Privacy Policy"
        case .acknowledgements: "Acknowledgements"
        }
    }

    var icon: String {
        switch self {
        case .terms: "doc.text.fill"
        case .privacy: "hand.raised.fill"
        case .acknowledgements: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .terms: .gray
        case .privacy: .blue
        case .acknowledgements: .purple
        }
    }

    /// Metnin en son güncellendiği tarih; içerik değişince elle güncellenmeli.
    var lastUpdated: Date {
        DateComponents(calendar: .current, year: 2026, month: 10, day: 25).date ?? .now
    }

    var sections: [Section] {
        switch self {
        case .terms:
            [
                Section(
                    heading: "Using Flow",
                    body: "Flow is a personal budgeting tool that helps you record your income and expenses. By using the app you agree to these terms. If you do not agree, please do not use Flow."
                ),
                Section(
                    heading: "Not Financial Advice",
                    body: "Charts, summaries and insights in Flow are based only on the data you enter. They are for your personal information and are not financial, tax or investment advice."
                ),
                Section(
                    heading: "Your Data",
                    body: "You are responsible for the accuracy of the transactions you record. Your data stays on your device and, if you turn on iCloud Sync, in your own iCloud account. We recommend keeping iCloud Sync on so your data is backed up."
                ),
                Section(
                    heading: "Availability",
                    body: "Flow is provided \"as is\". We work to keep it reliable, but we cannot guarantee it will always be free of errors or that data can be recovered after it is deleted or lost."
                ),
                Section(
                    heading: "Changes",
                    body: "We may update these terms when the app changes. The latest version is always available in Settings > About."
                ),
                Section(
                    heading: "Contact",
                    body: "Questions about these terms? Write to us at info.flow@gmail.com."
                )
            ]
        case .privacy:
            [
                Section(
                    heading: "Summary",
                    body: "Flow does not collect, sell or share your personal data. There are no accounts, ads, analytics or tracking in the app."
                ),
                Section(
                    heading: "What Flow Stores",
                    body: "Transactions, categories, notes, your budget, your name and your profile photo are stored only on your device. We never receive a copy of them."
                ),
                Section(
                    heading: "iCloud Sync",
                    body: "If you turn on iCloud Sync, your transactions are stored in your private iCloud database using Apple's CloudKit so they appear on your other devices. This data is protected by your Apple Account and is not accessible to us. You can turn sync off at any time in Settings > iCloud Sync."
                ),
                Section(
                    heading: "Assistant",
                    body: "The assistant runs entirely on your device. Its model is downloaded once from Hugging Face; that download, like any web request, reveals your IP address to the server. Your questions and transactions never leave your device."
                ),
                Section(
                    heading: "Face ID and Passcode",
                    body: "App Lock uses Face ID, Touch ID or your device passcode through iOS. Flow only learns whether the check succeeded; your biometric data never leaves the Secure Enclave."
                ),
                Section(
                    heading: "Notifications",
                    body: "Reminders are scheduled on your device. Flow does not use a server to send them, and you can turn them off at any time."
                ),
                Section(
                    heading: "Deleting Your Data",
                    body: "Deleting Flow removes all data stored on your device. To remove synced data, open the Settings app, tap your name, then iCloud > Manage Account Storage > Flow."
                ),
                Section(
                    heading: "Contact",
                    body: "If you have questions about your privacy, write to us at info.flow@gmail.com."
                )
            ]
        case .acknowledgements:
            [
                Section(
                    heading: "Built with Apple Technologies",
                    body: "Flow is built with Apple frameworks, including SwiftUI, SwiftData, CloudKit, Swift Charts and Local Authentication."
                ),
                Section(
                    heading: "On-Device Assistant",
                    body: "The assistant uses Google's Gemma 4 E2B model and the LiteRT-LM runtime, through the swift-litert-lm package. They are licensed under the Apache License, Version 2.0 (apache.org/licenses/LICENSE-2.0)."
                ),
                Section(
                    heading: "Icons",
                    body: "Icons in the app are SF Symbols, provided by Apple."
                ),
                Section(
                    heading: "Thank You",
                    body: "Thanks for using Flow and for every bit of feedback that makes it better."
                )
            ]
        }
    }
}
