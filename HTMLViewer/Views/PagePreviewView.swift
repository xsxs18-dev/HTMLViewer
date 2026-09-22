import SwiftUI

struct PagePreviewView: View {
    let item: PageItem

    @State private var content = ""
    @State private var isEditing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            HVColor.background.ignoresSafeArea()
            if isEditing {
                TextEditor(text: $content)
                    .scrollContentBackground(.hidden)
                    .background(HVColor.background)
                    .foregroundStyle(HVColor.textPrimary)
                    .font(HVFont.code)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(HVSpacing.sm)
            } else {
                WebView(htmlContent: content, baseURL: item.url.deletingLastPathComponent())
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HVColor.background, for: .navigationBar)
        .toolbarColorScheme(ThemeManager.shared.current.colorScheme, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Preview" : "Edit") {
                    toggleMode()
                }
                .foregroundStyle(HVColor.accent)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in if !isPresented { errorMessage = nil } }
        ), presenting: errorMessage) { _ in
            Button("OK") { errorMessage = nil }
        } message: { message in
            Text(message)
        }
        .onAppear(perform: load)
    }

    private func load() {
        content = (try? String(contentsOf: item.url, encoding: .utf8)) ?? ""
    }

    private func toggleMode() {
        if isEditing {
            save()
        }
        isEditing.toggle()
    }

    private func save() {
        do {
            try content.data(using: .utf8)?.write(to: item.url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
