import SwiftUI

struct LiquidGlassTheme {
    static let panelBackground = AnyShapeStyle(.ultraThinMaterial)
    static let cardBackground = AnyShapeStyle(.thinMaterial)
    static let cornerRadius: CGFloat = 18

    static let tint = LinearGradient(
        colors: [Color.cyan.opacity(0.16), Color.blue.opacity(0.08), Color.white.opacity(0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let stroke = Color.white.opacity(0.25)
    static let shadow = Color.black.opacity(0.16)
}
