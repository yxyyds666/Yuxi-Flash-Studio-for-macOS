import SwiftUI
import AppKit

struct GlobalLogConsoleView: View {
    @Bindable var logStore: AppLogStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("运行日志", systemImage: "text.alignleft")
                    .font(.headline)
                Spacer()
                Button("清空") {
                    logStore.clear()
                }
                Button("导出日志") {
                    exportLogs()
                }
            }

            ScrollView {
                Text(logStore.combinedText.isEmpty ? "暂无运行日志" : logStore.combinedText)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(12)
        .background(LiquidGlassTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.shadow, radius: 12, y: 6)
    }

    private func exportLogs() {
        let panel = NSSavePanel()
        panel.title = "导出运行日志"
        panel.nameFieldStringValue = defaultFileName
        panel.allowedContentTypes = [.plainText]

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try logStore.combinedText.write(to: url, atomically: true, encoding: .utf8)
                logStore.append(source: "系统", message: "日志已导出：\(url.path)")
            } catch {
                logStore.append(source: "系统", message: "日志导出失败：\(error.localizedDescription)")
            }
        }
    }

    private var defaultFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "yuxi-flash-studio-log-\(formatter.string(from: Date())).txt"
    }
}
