import SwiftUI

/// Kaydırdıkça daralan büyük başlık + arama + gün seçici; altında içerik listelenir.
struct ExpandableNavigationBar<Content: View>: View {

    let title: LocalizedStringKey
    var itemCount: Int

    @Binding var searchText: String
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Int
    let selectedYear: Int

    @FocusState.Binding var searchFieldFocus: Bool

    @ViewBuilder var content: Content

    @State private var scrollProgress = 0.0
    @State private var scrollPosition = ScrollPosition()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                content
            }
            .safeAreaPadding(16)
            .safeAreaInset(edge: .top, spacing: 0) {
                ExpandableHeader(
                    title: title,
                    searchText: $searchText,
                    selectedDate: $selectedDate,
                    selectedMonth: $selectedMonth,
                    selectedYear: selectedYear,
                    searchFieldFocus: $searchFieldFocus,
                    scrollProgress: $scrollProgress
                )
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: searchFieldFocus)
        .scrollTargetBehavior(HeaderSnapScrollBehavior())
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .scrollPosition($scrollPosition)
        .onChange(of: itemCount) {
            snapHeaderAfterContentChange()
        }
    }

    /// İçerik değişince başlık yarım açık kalmasın diye en yakın durağa kaydırır.
    private func snapHeaderAfterContentChange() {
        if scrollProgress >= 0.59 {
            withAnimation(AppAnimation.selection) {
                scrollPosition.scrollTo(y: 100)
            }
        } else if scrollProgress > 0 {
            withAnimation(AppAnimation.selection) {
                scrollPosition.scrollTo(y: 0)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now
    @Previewable @State var selectedMonth = Calendar.current.component(.month, from: .now)
    @Previewable @State var searchText = ""
    @Previewable @FocusState var isFocused: Bool

    ExpandableNavigationBar(
        title: "Home",
        itemCount: 5,
        searchText: $searchText,
        selectedDate: $selectedDate,
        selectedMonth: $selectedMonth,
        selectedYear: Calendar.current.component(.year, from: .now),
        searchFieldFocus: $isFocused
    ) {
        RoundedRectangle(cornerRadius: 24)
            .frame(height: 300)
    }
}
