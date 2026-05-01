import SwiftUI

struct DeviceStatusCardView: View {
    let device: DeviceInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Device")
                .font(.headline)
            Divider()
            Label(device.state, systemImage: device.state == "device" ? "checkmark.circle.fill" : "bolt.horizontal.circle")
                .foregroundStyle(device.state == "device" ? .green : .orange)
            LabeledContent("Serial", value: device.serial)
            LabeledContent("Model", value: device.model)
        }
        .padding(12)
        .background(LiquidGlassTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
    }
}
