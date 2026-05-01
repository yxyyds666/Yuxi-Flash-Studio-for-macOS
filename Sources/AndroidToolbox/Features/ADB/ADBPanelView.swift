import SwiftUI

struct ADBPanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ADB")
                .font(.largeTitle.bold())
            Text("ADB 功能模块正在初始化。下一步会接入设备检测、shell/install/pull/push 与日志面板。")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(20)
        .background(LiquidGlassTheme.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
    }
}
