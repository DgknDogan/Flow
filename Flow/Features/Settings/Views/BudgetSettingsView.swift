import SwiftUI

struct BudgetSettingsView: View {

    @Environment(AppState.self) private var appState

    @State private var budgetText = ""
    @FocusState private var isBudgetFieldFocused: Bool

    var body: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Text(verbatim: appState.currency.actualSymbol)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    // Metin alanı canlı aylık önizleme için String tutar; okuma/yazma yerel
                    // biçimle yapılır (ör. tr_TR'de "12,50").
                    TextField("0.00", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .font(.title2.weight(.semibold))
                        .focused($isBudgetFieldFocused)
                        .accessibilityLabel("Daily limit")

                    if !budgetText.isEmpty {
                        Button("Clear", systemImage: "xmark.circle.fill", action: clearBudgetText)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.tertiary)
                            .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
            } header: {
                Text("Daily Limit")
            } footer: {
                Text("Set the amount you plan to spend each day. Leave empty to disable.")
            }

            if let monthlyLimit {
                Section {
                    HStack {
                        Text("Monthly Limit")
                        Spacer()
                        MoneyText(monthlyLimit)
                            .fontWeight(.semibold)
                            .foregroundStyle(.indigo)
                            .contentTransition(.numericText())
                    }
                    .accessibilityElement(children: .combine)
                } footer: {
                    Text("Daily limit × \(Date.daysInCurrentMonth) days in \(Date.now, format: .dateTime.month(.wide)).")
                }
            }

            // Bütçe uyarıları henüz bildirim göndermediği için "Warning Threshold" bölümü gizlendi.
            if appState.dailySpendingLimit != nil {
                Section {
                    Button(role: .destructive, action: removeBudget) {
                        Text("Remove Budget")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .insetGroupedScreen("Budget")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: saveBudget)
                    .disabled(!isDirty)
                    .fontWeight(.semibold)
            }

            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: loadBudgetText)
    }

    private var trimmedText: String {
        budgetText.trimmingCharacters(in: .whitespaces)
    }

    /// Girilen geçerli (sıfırdan büyük) günlük limit; boş ya da geçersizse `nil`.
    private var enteredLimit: Double? {
        guard !trimmedText.isEmpty, let value = try? Double(trimmedText, format: .number), value > 0 else {
            return nil
        }
        return value
    }

    /// Girilen günlük limitin içinde bulunulan aya karşılığı (kaydetmeden önce de canlı gösterilir).
    private var monthlyLimit: Double? {
        enteredLimit.map { $0 * Double(Date.daysInCurrentMonth) }
    }

    private var isDirty: Bool {
        if trimmedText.isEmpty {
            return appState.dailySpendingLimit != nil
        }
        guard let enteredLimit else { return false }
        return enteredLimit != appState.dailySpendingLimit
    }

    private func loadBudgetText() {
        guard let budget = appState.dailySpendingLimit else { return }
        budgetText = Self.fieldText(for: budget)
    }

    private func saveBudget() {
        if trimmedText.isEmpty {
            appState.dailySpendingLimit = nil
        } else if let enteredLimit {
            appState.dailySpendingLimit = enteredLimit
            budgetText = Self.fieldText(for: enteredLimit)
        }
        isBudgetFieldFocused = false
    }

    private func removeBudget() {
        appState.dailySpendingLimit = nil
        budgetText = ""
    }

    private func clearBudgetText() {
        budgetText = ""
    }

    private func dismissKeyboard() {
        isBudgetFieldFocused = false
    }

    private static func fieldText(for value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)).grouping(.never))
    }
}

#Preview {
    NavigationStack {
        BudgetSettingsView()
            .environment(AppState())
    }
}
