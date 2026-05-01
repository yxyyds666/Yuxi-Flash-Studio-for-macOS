import SwiftUI

struct FastbootPanelView: View {
    @Bindable var viewModel: FastbootViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Fastboot")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Refresh Devices") {
                    viewModel.refreshDevices()
                }
            }

            GroupBox("Getvar") {
                HStack {
                    TextField("variable key", text: $viewModel.varKey)
                    Button("Read") { viewModel.readVar() }
                }
            }

            HStack(spacing: 10) {
                Button("Reboot Bootloader") { viewModel.rebootBootloader() }
                Button("Reboot") { viewModel.reboot() }
            }

            GroupBox("Logs") {
                ScrollView {
                    Text(viewModel.logs.isEmpty ? "No logs yet" : viewModel.logs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 220)
            }

            Spacer()
        }
        .padding(20)
        .background(LiquidGlassTheme.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .onAppear {
            viewModel.refreshDevices()
        }
    }
}
