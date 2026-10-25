import SwiftUI

struct PrimaryButton<S: ShapeStyle, Content: View>: View {
    
    let height: CGFloat
    let style: S
    let action: () -> Void
    @ViewBuilder let content: Content
    
    @Environment(\.isEnabled) private var isEnabled
    
    init(
        height: CGFloat = 50,
        style: S = .tint,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.style = style
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: height)
                .background(style)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: AppRadius.card))
                .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut, value: isEnabled)
    }
}


#Preview {
    PrimaryButton(height: 55) {

    } content: {
        Label("Press", systemImage: "apple.logo")
    }
    .disabled(false)

}
