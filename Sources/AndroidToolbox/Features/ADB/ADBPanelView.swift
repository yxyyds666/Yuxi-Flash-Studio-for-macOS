import SwiftUI

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel
    private let rebootColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("ADB")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button("刷新设备") {
                        viewModel.refreshDevices()
                    }
                }

                GroupBox("快速重启") {
                    LazyVGrid(columns: rebootColumns, spacing: 10) {
                        ForEach(viewModel.rebootActions) { action in
                            Button {
                                viewModel.reboot(to: action.target, label: action.title)
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: iconName(for: action.target))
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Text(action.title)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 84, alignment: .center)
                                .padding(10)
                                .background(LiquidGlassTheme.cardBackground)
                                .overlay {
                                    RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                                        .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
                                .shadow(color: LiquidGlassTheme.shadow, radius: 10, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                GroupBox("日志") {
                    ScrollView {
                        Text(viewModel.logs.isEmpty ? "暂无日志" : viewModel.logs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(minHeight: 120, maxHeight: 180)
                }
            }
            .padding(20)
        }
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

    private func iconName(for target: ADBRebootTarget) -> String {
        switch target {
        case .system:
            return "power"
        case .fastboot:
            return "hare.fill"
        case .bootloader:
            return "gearshape.2.fill"
        case .edl:
            return "bolt.fill"
        case .recovery:
            return "cross.case.fill"
        case .sideload:
            return "arrow.down.circle.fill"
        }
    }
}
