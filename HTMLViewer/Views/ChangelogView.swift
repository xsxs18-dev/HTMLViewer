import SwiftUI

struct ChangelogView: View {
    @State private var entries: [ChangelogEntry] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            HVColor.background.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else if let errorMessage {
                VStack(spacing: HVSpacing.md) {
                    Text(errorMessage)
                        .foregroundStyle(HVColor.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, HVSpacing.lg)
                    Button("Retry") { load() }
                        .foregroundStyle(HVColor.accent)
                }
            } else {
                List(entries) { entry in
                    VStack(alignment: .leading, spacing: HVSpacing.xs) {
                        HStack {
                            Text(entry.displayVersion)
                                .font(HVFont.headline)
                                .foregroundStyle(HVColor.textPrimary)
                            Spacer()
                            if let date = entry.displayDate {
                                Text(date)
                                    .font(HVFont.caption)
                                    .foregroundStyle(HVColor.textSecondary)
                            }
                        }
                        Text(entry.displayChanges)
                            .font(HVFont.body)
                            .foregroundStyle(HVColor.textSecondary)
                    }
                    .padding(.vertical, HVSpacing.xs)
                    .listRowBackground(HVColor.surface)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Changelog")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HVColor.background, for: .navigationBar)
        .toolbarColorScheme(ThemeManager.shared.current.colorScheme, for: .navigationBar)
        .onAppear {
            if entries.isEmpty { load() }
        }
    }

    private func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await UpdateChecker.shared.fetchChangelog()
                await MainActor.run {
                    entries = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
