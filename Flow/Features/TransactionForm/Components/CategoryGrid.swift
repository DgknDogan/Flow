import SwiftUI

/// Kategorileri `allCases` sırasıyla üç sütunlu ızgarada gösterir; yeni bir kategori otomatik eklenir.
struct CategoryGrid<Category: CategoryProtocol>: View {

    @Binding var selection: Category

    @Namespace private var selectionNamespace

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 3), spacing: 10) {
            ForEach(Array(Category.allCases), id: \.self) { category in
                Button {
                    select(category)
                } label: {
                    CategoryTile(category: category, isSelected: category == selection, namespace: selectionNamespace)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                .accessibilitySelected(category == selection)
            }
        }
    }

    private func select(_ category: Category) {
        withAnimation(AppAnimation.selection) {
            selection = category
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selection: ExpenseCategory = .housing
    CategoryGrid(selection: $selection)
        .padding()
}
