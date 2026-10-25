import SwiftUI

/// Cam efektli, yuvarlak, yalnızca ikonlu buton. Başlık görünmez ama VoiceOver'da okunur.
/// `glassID` aynı `GlassEffectContainer` içindeki butonların birbirine dönüşerek geçmesini sağlar.
struct GlassIconButton: View {

    let title: LocalizedStringKey
    let systemImage: String
    let glassID: String
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.title2)
                .frame(width: AppLayout.minimumTapSize, height: AppLayout.minimumTapSize)
                // Buton içinde `.primary` tint rengine çözülür; etiket rengi açıkça verilir.
                .foregroundStyle(Color.primary)
                .contentTransition(.symbolEffect)
        }
        .glassEffect(.clear.interactive(false), in: .circle)
        .glassEffectID(glassID, in: namespace)
        .glassEffectTransition(.matchedGeometry)
    }
}
