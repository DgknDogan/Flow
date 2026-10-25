import SwiftUI

struct ShimmerContainer: View {

    let config: ShimmerConfig

    var body: some View {
        RoundedRectangle(cornerRadius: config.cornerRadius)
            .frame(maxWidth: config.width)
            .frame(height: config.height)
            .shimmer()
    }
}

#Preview {
    ShimmerContainer(config: .init(height: 200))
        .padding()
}
