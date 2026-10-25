import SwiftUI

/// Satır sola kaydırıldıkça sağda açılan kırmızı silme alanı.
struct SwipeDeleteButton: View {

    let revealedWidth: Double
    let height: Double
    let isFullyRevealed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "trash.fill")
                    .font(.title3)

                if revealedWidth > 50 {
                    Text("Delete")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .opacity(isFullyRevealed ? 0 : 1)
            .foregroundStyle(.white)
            .frame(width: revealedWidth)
            .frame(height: height)
            .background(
                LinearGradient(
                    colors: [.red, .red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .buttonStyle(.plain)
        .opacity(revealedWidth == 0 ? 0 : 1)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .contentShape(.rect)
        // VoiceOver satırdaki "Delete" eylemini kullanır; görsel buton gizlenir.
        .accessibilityHidden(true)
    }
}
