import SwiftUI

/// Dönem türü seçici (hafta/ay/yıl) ve önceki/sonraki döneme geçiş.
/// Liste hücreleri içeriklerini kartın yuvarlak köşelerine göre kırptığı için seçici satır
/// olarak değil, bölüm başlığı olarak çizilir; böylece köşeleri kesilmez.
struct PeriodPickerSection: View {

    @Binding var selection: DateTabs
    let title: String
    let canShowNextPeriod: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        Section {
        } header: {
            VStack(spacing: 12) {
                SegmentedPicker(title: "Date Range", selection: $selection)

                HStack {
                    Button("Previous Period", systemImage: "chevron.backward", action: onPrevious)
                        .accessibilityIdentifier("previousPeriodButton")

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("periodTitle")

                    Button("Next Period", systemImage: "chevron.forward", action: onNext)
                        .disabled(!canShowNextPeriod)
                        .accessibilityIdentifier("nextPeriodButton")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.large)
            }
            // Başlık stili (küçük, ikincil renkli, büyük harfli metin) içeriğe geçmesin.
            .font(.body)
            .textCase(nil)
            .listRowInsets(EdgeInsets())
        }
        .listSectionSpacing(10)
    }
}

#Preview {
    @Previewable @State var selection: DateTabs = .month
    List {
        PeriodPickerSection(selection: $selection, title: "October 2026", canShowNextPeriod: false, onPrevious: {}, onNext: {})
    }
}
