import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var current: HVTheme

    private let defaults = UserDefaults.standard
    private let key = "HTMLViewer.selectedTheme"

    private init() {
        if let raw = defaults.string(forKey: key), let id = HVThemeID(rawValue: raw) {
            current = HVTheme.theme(for: id)
        } else {
            current = .lightBlueDark
        }
    }

    func select(_ id: HVThemeID) {
        current = HVTheme.theme(for: id)
        defaults.set(id.rawValue, forKey: key)
    }
}
