import SwiftUI

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ADB")
                    .font(.largeTitle.bold())
                Spacer()
                Button("刷新设备") {
                    viewModel.refreshDevices()
                }
            }

            GroupBox("Shell 命令") {
                HStack {
                    TextField("输入 shell 命令", text: $viewModel.shellCommand)
                    Button("执行") { viewModel.executeShell() }
                }
            }

            GroupBox("安装 APK") {
                HStack {
                    TextField("/路径/应用.apk", text: $viewModel.apkPath)
                    Button("安装") { viewModel.installApk() }
                }
            }

            GroupBox("拉取文件 (Pull)") {
                HStack {
                    TextField("远端路径", text: $viewModel.pullRemotePath)
                    TextField("本地路径", text: $viewModel.pullLocalPath)
                    Button("拉取") { viewModel.pullFile() }
                }
            }

            GroupBox("推送文件 (Push)") {
                HStack {
                    TextField("本地路径", text: $viewModel.pushLocalPath)
                    TextField("远端路径", text: $viewModel.pushRemotePath)
                    Button("推送") { viewModel.pushFile() }
                }
            }

            GroupBox("日志") {
                ScrollView {
                    Text(viewModel.logs.isEmpty ? "暂无日志" : viewModel.logs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 160)
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
