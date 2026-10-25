import SwiftUI

/// Renkli zemin üzerinde beyaz SF Symbol: ayar, kategori ve rozet ikonlarının ortak görünümü.
/// Yalnızca görsel olduğu için VoiceOver'dan gizlenir; anlamı yanındaki metin taşır.
struct IconTile: View {

    enum TileShape {
        case roundedSquare
        case circle
    }

    let systemName: String
    let tint: Color
    var size = 30.0
    var shape: TileShape = .roundedSquare
    var font: Font = .footnote.weight(.semibold)

    @ScaledMetric(relativeTo: .body) private var scale = 1.0

    var body: some View {
        Image(systemName: systemName)
            .font(font)
            .foregroundStyle(.white)
            .frame(width: size * scale, height: size * scale)
            .background(tint.gradient, in: backgroundShape)
            .accessibilityHidden(true)
    }

    private var backgroundShape: AnyShape {
        switch shape {
        case .roundedSquare: AnyShape(.rect(cornerRadius: AppRadius.icon))
        case .circle: AnyShape(.circle)
        }
    }
}

#Preview {
    HStack {
        IconTile(systemName: "bell.fill", tint: .orange)
        IconTile(systemName: "fork.knife", tint: .red, size: 40, shape: .circle, font: .body)
    }
}
