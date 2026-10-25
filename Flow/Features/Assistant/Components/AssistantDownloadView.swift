import SwiftUI

/// Asistanın modeli cihaza inene kadar sohbetin yerinde durur: ilerlemeyi, mobil veri seçimini ve
/// hataları gösterir.
struct AssistantDownloadView: View {

    let state: GemmaModelDownloader.State
    /// İndirmeyi başlatır; parametre mobil veriye izin verilip verilmediği.
    var onDownload: (_ allowingCellular: Bool) -> Void = { _ in }
    var onRetry: () -> Void = {}

    private var size: String {
        GemmaModelDownloader.expectedBytes.formatted(.byteCount(style: .file))
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            actions
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch state {
        case .downloading(let progress):
            ProgressView(value: progress)
                .frame(width: 220)
            Text(progress, format: .percent.precision(.fractionLength(0)))
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
        case .awaitingCellularConsent:
            Button("Download Now") { onDownload(true) }
                .buttonStyle(.borderedProminent)
            Button("Wait for Wi-Fi") { onDownload(false) }
        case .waitingForWiFi:
            Button("Download Using Mobile Data") { onDownload(true) }
        case .failed, .insufficientStorage:
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        case .notDownloaded, .ready:
            ProgressView()
        }
    }

    private var title: LocalizedStringResource {
        switch state {
        case .downloading, .notDownloaded, .ready: "Downloading the Assistant"
        case .awaitingCellularConsent: "Download the Assistant"
        case .waitingForWiFi: "Waiting for Wi-Fi"
        case .insufficientStorage: "Not Enough Storage"
        case .failed: "Download Failed"
        }
    }

    private var message: LocalizedStringResource {
        switch state {
        case .downloading, .notDownloaded, .ready:
            "The assistant runs on your device. Flow is downloading its \(size) model in the background; you can keep using the app."
        case .awaitingCellularConsent:
            "The assistant needs a \(size) model. You're on mobile data, so downloading it may count toward your data plan."
        case .waitingForWiFi:
            "The \(size) model will download automatically when you connect to Wi-Fi."
        case .insufficientStorage:
            "The assistant's model needs about \(size) of free space. Free up some storage and try again."
        case .failed:
            "The assistant's model couldn't be downloaded. Check your connection and try again."
        }
    }

    private var systemImage: String {
        switch state {
        case .waitingForWiFi: "wifi"
        case .insufficientStorage: "externaldrive.badge.exclamationmark"
        case .failed: "exclamationmark.icloud"
        default: "arrow.down.circle"
        }
    }
}

#Preview {
    AssistantDownloadView(state: .downloading(progress: 0.42))
}
