import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FileBrowserView(directory: FileSystemService.shared.rootURL, title: String(localized: "My Pages"))
            }
            .tabItem {
                Label("Pages", systemImage: "chevron.left.slash.chevron.right")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(HVColor.accent)
    }
}
