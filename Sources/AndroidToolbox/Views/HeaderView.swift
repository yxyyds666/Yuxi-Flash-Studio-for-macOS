import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox.circle.fill")
                .font(.system(size: 28))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .pink)
            VStack(alignment: .leading, spacing: 2) {
                Text("安卓刷机工具箱")
                    .font(.title3.bold())
                Text("ADB · Fastboot · EDL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(LiquidGlassTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.shadow, radius: 16, y: 8)
    }
}
