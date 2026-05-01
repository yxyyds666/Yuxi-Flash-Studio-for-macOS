import SwiftUI

struct DeviceStatusCardView: View {
    let device: DeviceInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("设备状态")
                .font(.headline)
            Divider()
            Label(device.state, systemImage: device.isOnline ? "checkmark.circle.fill" : "bolt.horizontal.circle")
                .foregroundStyle(device.isOnline ? .green : .orange)
            LabeledContent("序列号", value: device.serial)
            LabeledContent("机型", value: device.model)
        }
        .padding(12)
        .background(LiquidGlassTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.shadow, radius: 14, y: 6)
    }
}
