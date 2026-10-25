import SwiftUI

struct DateSelectionView: View {

    @Binding var selectedDate: Date
    let onBack: () -> Void

    /// Takvimin yüksekliği açıldığı aya göre (5 satır) hesaplanınca 6 satırlı aylara geçildiğinde
    /// satırlar sıkışıyor ve UIKit "UICalendarView's height is smaller…" uyarısı veriyordu.
    /// Yükseklik 6 satıra göre sabitlenir ve metin boyutuyla büyür.
    @ScaledMetric(relativeTo: .body) private var calendarHeight = 390.0

    var body: some View {
        VStack(spacing: 12) {
            SheetHeader("Transaction Details", action: onBack)

            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .frame(height: calendarHeight)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var date = Date.now
    DateSelectionView(selectedDate: $date) { }
        .padding()
}
