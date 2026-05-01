import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox.circle.fill")
                .font(.system(size: 26))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Android Toolbox")
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
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
    }
}
