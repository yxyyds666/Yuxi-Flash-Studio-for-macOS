import SwiftUI
import AppKit

struct GlobalLogConsoleView: View {
    @Bindable var logStore: AppLogStore

    private let bottomAnchorID = "log-bottom"

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

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(logStore.combinedText.isEmpty ? "暂无运行日志" : logStore.combinedText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)

                        Color.clear
                            .frame(height: 1)
                            .id(bottomAnchorID)
                    }
                }
                .frame(maxHeight: .infinity)
                .onAppear {
                    scrollToBottom(using: proxy)
                }
                .onChange(of: logStore.entries.count) { _, _ in
                    scrollToBottom(using: proxy)
                }
            }
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

    private func scrollToBottom(using proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        }
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
