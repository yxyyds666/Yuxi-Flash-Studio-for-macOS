import SwiftUI

enum ToolboxSidebarSection: Hashable {
    case adb
    case fastboot
    case edl
}

struct ModeSidebarView: View {
    @Binding var mode: ToolboxMode
    @Binding var expandedSection: ToolboxSidebarSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("工具箱")
                .font(.headline)

            sectionCard(
                title: "ADB 工具箱",
                section: .adb,
                targetMode: .adb,
                items: ["设备列表", "快速重启"]
            )

            sectionCard(
                title: "Fastboot 工具箱",
                section: .fastboot,
                targetMode: .fastboot,
                items: ["设备检测", "变量读取", "重启控制"]
            )

            sectionCard(
                title: "EDL 工具箱",
                section: .edl,
                targetMode: .edl,
                items: ["9008 探测", "原始命令"]
            )
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

    private func sectionCard(title: String, section: ToolboxSidebarSection, targetMode: ToolboxMode, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                mode = targetMode
                expandedSection = section
            } label: {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: expandedSection == section ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(mode == targetMode ? LiquidGlassTheme.cardBackground : AnyShapeStyle(Color.clear))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            if expandedSection == section {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        Text("• \(item)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: expandedSection)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(LiquidGlassTheme.stroke.opacity(0.7), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
