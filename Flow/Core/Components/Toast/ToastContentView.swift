import SwiftUI

struct ToastContentView: View {

    let toast: Toast
    let isExpanded: Bool
    let hasDynamicIsland: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.kind.symbol)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white, toast.kind.tint)
                .symbolEffect(.wiggle, options: .default.speed(1.5), value: isExpanded)
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                if hasDynamicIsland {
                    Spacer(minLength: 0)
                }

                Text(toast.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)

                // Kap yüksekliği sabit olduğundan tek satır; uzun mesajlar biraz küçülür.
                Text(toast.message)
                    .font(.caption)
                    .foregroundStyle(.white.secondary)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, hasDynamicIsland ? 12 : 0)
            .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .compositingGroup()
        .blur(radius: isExpanded ? 0 : 5)
        .opacity(isExpanded ? 1 : 0)
    }
}
