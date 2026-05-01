import SwiftUI

struct FastbootPanelView: View {
    @Bindable var viewModel: FastbootViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Fastboot")
                    .font(.largeTitle.bold())
                Spacer()
                Button("刷新设备") {
                    viewModel.refreshDevices()
                }
            }

            GroupBox("读取变量 (getvar)") {
                HStack {
                    TextField("变量名", text: $viewModel.varKey)
                    Button("读取") { viewModel.readVar() }
                }
            }

            HStack(spacing: 10) {
                Button("重启到 Bootloader") { viewModel.rebootBootloader() }
                Button("重启设备") { viewModel.reboot() }
            }

            Spacer()
        }
        .padding(20)
        .background(LiquidGlassTheme.panelBackground)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.shadow, radius: 18, y: 8)
        .onAppear {
            viewModel.refreshDevices()
        }
    }
}
