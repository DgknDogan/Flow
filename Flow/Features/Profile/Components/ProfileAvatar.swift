import SwiftUI

/// Profil fotoğrafını, yoksa isim baş harflerini (o da yoksa kişi simgesini) daire içinde gösterir.
struct ProfileAvatar: View {

    let image: UIImage?
    let name: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.gradient)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let initials {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
        .accessibilityHidden(true)
    }

    private var initials: String? {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        return letters.isEmpty ? nil : String(letters).uppercased()
    }
}
