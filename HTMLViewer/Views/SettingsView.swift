import SwiftUI

struct SettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var updateResult: UpdateCheckResult?
    @State private var updateError: String?
    @State private var isChecking = false

    var body: some View {
        ZStack {
            HVColor.background.ignoresSafeArea()
            List {
                Section {
                    VStack(spacing: HVSpacing.sm) {
                        Image(systemName: "chevron.left.slash.chevron.right")
                            .font(.system(size: 44))
                            .foregroundStyle(HVColor.accent)
                        Text("HTMLViewer")
                            .font(HVFont.headline)
                            .foregroundStyle(HVColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HVSpacing.md)
                    .listRowBackground(HVColor.background)
                }

                Section {
                    ForEach(HVThemeID.allCases) { id in
                        themeRow(for: id)
                    }
                } header: {
                    Text("Appearance")
                        .foregroundStyle(HVColor.textSecondary)
                }
                .listRowBackground(HVColor.surface)

                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(HVColor.textPrimary)
                        Spacer()
                        Text(currentVersionLabel)
                            .foregroundStyle(HVColor.textSecondary)
                    }

                    Button {
                        checkForUpdate()
                    } label: {
                        HStack {
                            Text(isChecking ? "Checking…" : "Check for Updates")
                            Spacer()
                            if isChecking {
                                ProgressView()
                            }
                        }
                    }
                    .foregroundStyle(HVColor.accent)
                    .disabled(isChecking)

                    NavigationLink {
                        ChangelogView()
                    } label: {
                        Text("Changelog")
                            .foregroundStyle(HVColor.accent)
                    }

                    if let updateResult {
                        if updateResult.isUpdateAvailable {
                            Link(destination: updateResult.releaseURL) {
                                VStack(alignment: .leading, spacing: HVSpacing.xs) {
                                    Text("Update available: build \(updateResult.latestVersion)")
                                        .foregroundStyle(HVColor.accent)
                                    Text("Tap to open the release on GitHub and install it there.")
                                        .font(HVFont.caption)
                                        .foregroundStyle(HVColor.textSecondary)
                                }
                            }
                        } else {
                            Text("You're up to date.")
                                .foregroundStyle(HVColor.textSecondary)
                        }
                    }

                    if let updateError {
                        Text(updateError)
                            .foregroundStyle(HVColor.danger)
                    }
                } header: {
                    Text("Updates")
                        .foregroundStyle(HVColor.textSecondary)
                } footer: {
                    Text("These are the only network requests HTMLViewer ever makes — checking GitHub for release info and nothing else.")
                        .foregroundStyle(HVColor.textSecondary)
                }
                .listRowBackground(HVColor.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HVColor.background, for: .navigationBar)
        .toolbarColorScheme(ThemeManager.shared.current.colorScheme, for: .navigationBar)
    }

    private func themeRow(for id: HVThemeID) -> some View {
        let theme = HVTheme.theme(for: id)
        return Button {
            themeManager.select(id)
        } label: {
            HStack(spacing: HVSpacing.md) {
                HStack(spacing: -6) {
                    Circle().fill(theme.accent).frame(width: 22, height: 22)
                    Circle().fill(theme.background).frame(width: 22, height: 22)
                        .overlay(Circle().stroke(HVColor.border, lineWidth: 1))
                }
                Text(id.displayName)
                    .foregroundStyle(HVColor.textPrimary)
                Spacer()
                if themeManager.current.id == id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(HVColor.accent)
                }
            }
        }
    }

    private var currentVersionLabel: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "dev"
        return "\(version) (build \(build))"
    }

    private func checkForUpdate() {
        isChecking = true
        updateError = nil
        Task {
            do {
                let result = try await UpdateChecker.shared.checkForUpdate()
                await MainActor.run {
                    updateResult = result
                    isChecking = false
                }
            } catch {
                await MainActor.run {
                    updateError = error.localizedDescription
                    isChecking = false
                }
            }
        }
    }
}
