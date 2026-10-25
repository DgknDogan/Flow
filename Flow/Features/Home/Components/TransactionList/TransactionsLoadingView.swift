import SwiftUI

struct TransactionsLoadingView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShimmerContainer(config: .init(height: 20, width: 140))
                .padding(.bottom)

            ShimmerContainer(config: .init(height: 1000))
        }
        .accessibilityElement()
        .accessibilityLabel("Loading transactions")
    }
}
