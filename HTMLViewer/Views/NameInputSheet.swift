import SwiftUI

struct NameInputSheet: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let initialValue: String
    let confirmTitle: LocalizedStringKey
    let onConfirm: (String) -> Void

    @State private var name: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    init(
        title: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        initialValue: String = "",
        confirmTitle: LocalizedStringKey = "Create",
        onConfirm: @escaping (String) -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.initialValue = initialValue
        self.confirmTitle = confirmTitle
        self.onConfirm = onConfirm
        _name = State(initialValue: initialValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HVColor.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: HVSpacing.md) {
                    TextField(placeholder, text: $name)
                        .focused($isFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(HVSpacing.md)
                        .background(HVColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: HVRadius.sm, style: .continuous))
                        .foregroundStyle(HVColor.textPrimary)

                    Spacer()
                }
                .padding(HVSpacing.md)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(HVColor.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(confirmTitle) { confirm() }
                        .foregroundStyle(HVColor.accent)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.height(180)])
        .onAppear { isFocused = true }
    }

    private func confirm() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onConfirm(trimmed)
        dismiss()
    }
}
