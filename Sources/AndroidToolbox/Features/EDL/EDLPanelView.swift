import SwiftUI

struct EDLPanelView: View {
    @Bindable var viewModel: EDLViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("EDL (9008)")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Probe 9008") {
                    viewModel.refreshDevices()
                }
            }

            GroupBox("Raw Command") {
                HStack {
                    TextField("e.g. --help", text: $viewModel.rawCommand)
                    Button("Run") { viewModel.runRawCommand() }
                }
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
