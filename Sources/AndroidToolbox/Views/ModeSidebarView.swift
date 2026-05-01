import SwiftUI

struct ModeSidebarView: View {
    @Binding var mode: ToolboxMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("功能模式")
                .font(.headline)
            ForEach(ToolboxMode.allCases) { item in
                Button {
                    mode = item
                } label: {
                    HStack {
                        Text(item.rawValue)
                        Spacer()
                        if mode == item {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(mode == item ? Color.accentColor.opacity(0.22) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
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
}
