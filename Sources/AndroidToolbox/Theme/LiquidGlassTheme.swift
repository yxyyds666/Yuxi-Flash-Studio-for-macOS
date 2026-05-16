import SwiftUI

struct LiquidGlassTheme {
    static let panelBackground = AnyShapeStyle(.ultraThinMaterial)
    static let cardBackground = AnyShapeStyle(.thinMaterial)
    static let cornerRadius: CGFloat = 18

    static let tint = LinearGradient(
        colors: [Color.pink.opacity(0.22), Color.purple.opacity(0.12), Color.white.opacity(0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let stroke = Color.white.opacity(0.24)
    static let shadow = Color.pink.opacity(0.14)
    static let secondaryStroke = Color.white.opacity(0.16)
    static let secondaryShadow = Color.black.opacity(0.10)
}
