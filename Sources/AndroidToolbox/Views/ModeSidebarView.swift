import SwiftUI

struct ModeSidebarView: View {
    @Binding var mode: ToolboxMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mode")
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
                    .background(mode == item ? Color.accentColor.opacity(0.2) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(LiquidGlassTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
    }
}
