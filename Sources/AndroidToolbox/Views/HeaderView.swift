import SwiftUI
import AppKit

struct HeaderView: View {
    private var appIcon: NSImage? {
        guard let url = Bundle.module.url(forResource: "app-icon", withExtension: "png") else { return nil }
        return NSImage(contentsOf: url)
    }

    var body: some View {
        HStack(spacing: 12) {
            if let appIcon {
                Image(nsImage: appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: "shippingbox.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .pink)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Yuxi Flash Studio")
                    .font(.title3.bold())
                Text("ADB · Fastboot · EDL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button {
                NSApp.orderFrontStandardAboutPanel(nil)
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("应用信息", systemImage: "info.circle")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(LiquidGlassTheme.cardBackground)
        .background(LiquidGlassTheme.cardTint)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .fill(LiquidGlassTheme.glow)
                .opacity(0.35)
                .padding(1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.shadow, radius: 16, y: 8)
    }
}
