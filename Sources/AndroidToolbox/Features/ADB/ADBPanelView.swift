import SwiftUI

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ADB")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Refresh Devices") {
                    viewModel.refreshDevices()
                }
            }

            GroupBox("Shell") {
                HStack {
                    TextField("input shell command", text: $viewModel.shellCommand)
                    Button("Run") { viewModel.executeShell() }
                }
            }

            GroupBox("Install APK") {
                HStack {
                    TextField("/path/to/app.apk", text: $viewModel.apkPath)
                    Button("Install") { viewModel.installApk() }
                }
            }

            GroupBox("Pull") {
                HStack {
                    TextField("remote path", text: $viewModel.pullRemotePath)
                    TextField("local path", text: $viewModel.pullLocalPath)
                    Button("Pull") { viewModel.pullFile() }
                }
            }

            GroupBox("Push") {
                HStack {
                    TextField("local path", text: $viewModel.pushLocalPath)
                    TextField("remote path", text: $viewModel.pushRemotePath)
                    Button("Push") { viewModel.pushFile() }
                }
            }

            GroupBox("Logs") {
                ScrollView {
                    Text(viewModel.logs.isEmpty ? "No logs yet" : viewModel.logs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 160)
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
