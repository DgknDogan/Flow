import SwiftUI

/// `ExpandableNavigationBar`'ın üst kısmı. Kendini sabitlemek için kaydırma alanındaki
/// konumunu okuması gerektiğinden `GeometryReader` bilinçli olarak korunuyor.
struct ExpandableHeader: View {

    let title: LocalizedStringKey

    @Binding var searchText: String
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Int
    let selectedYear: Int

    @FocusState.Binding var searchFieldFocus: Bool
    @Binding var scrollProgress: Double

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView(axis: .vertical)).minY
            let rawProgress = max(min(-minY / 100, 1), 0)
            let progress = searchFieldFocus ? 1 : rawProgress

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text(title)
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                    .padding(.horizontal, 20)
                    .opacity(1 - progress)
                    .zIndex(100)
                    .accessibilityAddTraits(.isHeader)

                HStack(alignment: .center) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .accessibilityHidden(true)

                    TextField("Search Transactions", text: $searchText)
                        .focused($searchFieldFocus)
                        .allowsHitTesting(searchFieldFocus)
                        .accessibilityIdentifier("searchField")

                    Spacer()
                }
                .padding(.horizontal, 15 + (-progress * 15))
                .padding(.vertical, 15 + (-progress * 15))
                .background {
                    // Açıkken kart rengiyle zeminden ayrılır, daralınca altındaki içerik için malzemeye döner.
                    RoundedRectangle(cornerRadius: AppRadius.card * (1 - progress))
                        .fill(.ultraThickMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppRadius.card * (1 - progress))
                                .fill(Color(.secondarySystemGroupedBackground))
                                .opacity(1 - progress)
                        }
                        .padding(.top, -progress * 200)
                        .padding(.horizontal, -progress * 20)
                        .padding(.bottom, -progress * 86)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                // Kapsülün tamamı aramayı açar; alan küçük metin kutusundan geniştir.
                .onTapGesture(perform: focusSearchField)

                HorizontalDatePicker(selectedDay: $selectedDate, selectedMonth: $selectedMonth, year: selectedYear)
                    .contentMargins(.horizontal, 16)
            }
            .offset(y: minY < 0 || searchFieldFocus ? -minY : 0)
            .offset(y: -progress * 100)
            .onChange(of: rawProgress) { _, newValue in
                scrollProgress = newValue
            }
        }
        .frame(height: 260)
        .padding(.bottom, searchFieldFocus ? -100 * (1 - scrollProgress) : 0)
    }

    private func focusSearchField() {
        guard !searchFieldFocus else { return }
        withAnimation(.bouncy(duration: 0.3)) {
            searchFieldFocus = true
        }
    }
}
