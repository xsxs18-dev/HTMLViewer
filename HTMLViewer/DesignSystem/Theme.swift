import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum HVColor {
    static var background: Color { ThemeManager.shared.current.background }
    static var surface: Color { ThemeManager.shared.current.surface }
    static var surfaceElevated: Color { ThemeManager.shared.current.surfaceElevated }
    static var border: Color { ThemeManager.shared.current.border }
    static var accent: Color { ThemeManager.shared.current.accent }
    static var accentMuted: Color { ThemeManager.shared.current.accentMuted }
    static var textPrimary: Color { ThemeManager.shared.current.textPrimary }
    static var textSecondary: Color { ThemeManager.shared.current.textSecondary }
    static var danger: Color { ThemeManager.shared.current.danger }
}

enum HVSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum HVRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
}

enum HVFont {
    static let title = Font.system(.title2, design: .rounded).weight(.bold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
    static let code = Font.system(.body, design: .monospaced)
}

struct HVPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HVFont.headline)
            .foregroundStyle(Color.black)
            .padding(.vertical, HVSpacing.sm)
            .padding(.horizontal, HVSpacing.md)
            .background(HVColor.accent.opacity(configuration.isPressed ? 0.7 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: HVRadius.sm, style: .continuous))
    }
}

struct HVIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(HVColor.accent)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct HVCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(HVColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: HVRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HVRadius.md, style: .continuous)
                    .stroke(HVColor.border, lineWidth: 1)
            )
    }
}

extension View {
    func hvCard() -> some View {
        modifier(HVCardBackground())
    }
}

extension ButtonStyle where Self == HVPrimaryButtonStyle {
    static var hvPrimary: HVPrimaryButtonStyle { HVPrimaryButtonStyle() }
}

extension ButtonStyle where Self == HVIconButtonStyle {
    static var hvIcon: HVIconButtonStyle { HVIconButtonStyle() }
}
