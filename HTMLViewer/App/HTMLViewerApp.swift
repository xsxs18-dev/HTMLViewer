import SwiftUI

@main
struct HTMLViewerApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(ThemeManager.shared.current.colorScheme)
        }
    }
}
