import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: LedgerStore
    @Environment(\.dismiss) private var dismiss

    @State private var kind: TransactionKind = .expense
    @State private var amount = ""
    @State private var description = ""
    @State private var category: ExpenseCategory = .housing
    @State private var forWho = "Me"
    @State private var recurring = false

    private var parsedAmount: Decimal? {
        Decimal(string: amount.replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US"))
    }

    private var canSave: Bool {
        guard let parsedAmount else { return false }
        return parsedAmount > 0 && !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Picker("Transaction type", selection: $kind) {
                        Text("Expense").tag(TransactionKind.expense)
                        Text("Income").tag(TransactionKind.income)
                    }
                    .pickerStyle(.segmented)

                    LedgerField(title: "AMOUNT · MXN") {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.custom("Source Serif 4", size: 28).weight(.semibold))
                            .monospacedDigit()
                    }

                    LedgerField(title: "DESCRIPTION") {
                        TextField("Groceries", text: $description)
                            .textInputAutocapitalization(.sentences)
                    }

                    if kind == .expense {
                        VStack(alignment: .leading, spacing: 8) {
                            FieldTitle("CATEGORY")
                            ScrollView(.horizontal) {
                                HStack(spacing: 8) {
                                    ForEach(ExpenseCategory.allCases) { candidate in
                                        Button {
                                            category = candidate
                                        } label: {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(BancomerTheme.color(for: candidate))
                                                    .frame(width: 8, height: 8)
                                                Text(candidate.name)
                                            }
                                            .font(.custom("Libre Franklin", size: 12).weight(.medium))
                                            .padding(.horizontal, 11)
                                            .frame(height: 34)
                                            .background(category == candidate ? BancomerTheme.aqua.opacity(0.13) : Color.clear)
                                            .overlay {
                                                Capsule().stroke(category == candidate ? BancomerTheme.aqua : BancomerTheme.hairline, lineWidth: 1)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }

                    LedgerField(title: "FOR") {
                        TextField("Me", text: $forWho)
                            .textInputAutocapitalization(.words)
                    }

                    VStack(spacing: 0) {
                        Toggle(isOn: $recurring) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recurring")
                                    .font(.custom("Libre Franklin", size: 14))
                                Text("repeats monthly")
                                    .font(.custom("Libre Franklin", size: 10.5))
                                    .foregroundStyle(BancomerTheme.inkFaint)
                            }
                        }
                        .tint(BancomerTheme.aqua)
                        .padding(.vertical, 12)

                        Divider().overlay(BancomerTheme.hairline)

                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Today · \(FinanceFormat.shortDate(.now))")
                                .foregroundStyle(BancomerTheme.inkFaint)
                        }
                        .font(.custom("Libre Franklin", size: 13))
                        .padding(.vertical, 14)
                    }

                    Button("Save transaction") {
                        save()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color(red: 41 / 255, green: 78 / 255, blue: 124 / 255))
                    .frame(maxWidth: .infinity)
                    .disabled(!canSave)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(BancomerTheme.app.ignoresSafeArea())
            .navigationTitle("Add transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(BancomerTheme.aqua)
    }

    private func save() {
        guard let parsedAmount, canSave else { return }
        store.add(LedgerTransaction(
            kind: kind,
            amount: parsedAmount,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: kind == .income ? nil : category,
            forWho: forWho.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Me" : forWho,
            recurring: recurring
        ))
        Telemetry.log("transaction_saved")
        dismiss()
    }
}

private struct LedgerField<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            FieldTitle(title)
            content
                .font(.custom("Libre Franklin", size: 15))
                .padding(.horizontal, 12)
                .frame(minHeight: 48)
                .background(BancomerTheme.titlebar)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(BancomerTheme.hairline, lineWidth: 1)
                }
        }
    }
}

private struct FieldTitle: View {
    let value: String

    init(_ value: String) {
        self.value = value
    }

    var body: some View {
        Text(value)
            .font(.custom("Libre Franklin", size: 11).weight(.bold))
            .tracking(0.7)
            .foregroundStyle(BancomerTheme.inkDim)
    }
}
