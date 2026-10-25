import SwiftUI

/// Gönderilen mesajın kaynağından (giriş alanı ya da öneri kartı) sohbetteki balonuna uçtuğu
/// geçişin kimlikleri. Aynı kimliği taşıyan kaynak kaldırılıp balon eklenince SwiftUI çerçeveyi
/// birinden diğerine canlandırır; diğer balonlar kendi `message` kimliğiyle eşleşmesiz kalır.
nonisolated enum AssistantHeroID: Hashable {
    case draft
    case suggestion(Int)
    case message(UUID)
}

extension View {

    /// Kimlik ya da namespace verilmemişse (önizlemeler, akan cevap balonu) görünüm aynen kalır.
    /// Yalnızca konum eşlenir: boyut da eşlenseydi balon uçarken kaynağın çerçevesine sıkışır,
    /// metni "…" ile kesilir ya da tek satıra dizilip sonunda birden iki satıra geçerdi.
    @ViewBuilder
    func assistantHero(_ id: AssistantHeroID?, in namespace: Namespace.ID?) -> some View {
        if let id, let namespace {
            matchedGeometryEffect(id: id, in: namespace, properties: .position)
        } else {
            self
        }
    }
}
