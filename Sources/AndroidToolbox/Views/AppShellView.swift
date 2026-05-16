import SwiftUI

struct AppShellView: View {
    @State private var mode: ToolboxMode = .adb
    @State private var expandedSection: ToolboxSidebarSection = .adb
    @State private var appLogStore = AppLogStore()
    @State private var adbViewModel: ADBViewModel
    @State private var fastbootViewModel: FastbootViewModel
    @State private var edlViewModel: EDLViewModel

    init() {
        let logStore = AppLogStore()
        _appLogStore = State(initialValue: logStore)
        _adbViewModel = State(initialValue: ADBViewModel(appLogStore: logStore))
        _fastbootViewModel = State(initialValue: FastbootViewModel(appLogStore: logStore))
        _edlViewModel = State(initialValue: EDLViewModel(appLogStore: logStore))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.24), Color.purple.opacity(0.12), Color.black.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                HeaderView()

                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 10) {
                        mainPanel
                            .frame(maxHeight: .infinity)
                            .layoutPriority(1)

                        GlobalLogConsoleView(logStore: appLogStore)
                            .frame(height: 176)
                    }

                    rightSidebar
                        .frame(width: 276)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(12)
            .background(LiquidGlassTheme.panelBackground)
            .overlay {
                RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius + 4, style: .continuous)
                    .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius + 4, style: .continuous))
            .shadow(color: LiquidGlassTheme.shadow, radius: 18, y: 8)
            .padding(8)
        }
        .frame(width: 1280, height: 860)
        .background(WindowConfigurator())
    }

    @ViewBuilder
    private var mainPanel: some View {
        switch mode {
        case .adb:
            ADBPanelView(viewModel: adbViewModel)
        case .fastboot:
            FastbootPanelView(viewModel: fastbootViewModel)
        case .edl:
            EDLPanelView(viewModel: edlViewModel)
        }
    }

    private var rightSidebar: some View {
        VStack(spacing: 10) {
            DeviceStatusCardView(device: currentDevice)

            if mode == .adb {
                adbDeviceManagementCard
            }

            ModeSidebarView(mode: $mode, expandedSection: $expandedSection)
            Spacer()
        }
    }

    private var adbDeviceManagementCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("设备管理")
                    .font(.headline)
                Spacer()
                Button("刷新") {
                    adbViewModel.refreshDevices()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Divider()

            if adbViewModel.devices.isEmpty {
                Text("未检测到设备")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(adbViewModel.devices) { device in
                            Button {
                                adbViewModel.selectDevice(device)
                            } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(device.isOnline ? Color.green : Color.orange)
                                        .frame(width: 8, height: 8)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(device.model)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        Text(device.serial)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text(adbStateText(for: device.state))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(adbViewModel.selectedDevice.serial == device.serial ? LiquidGlassTheme.cardBackground : AnyShapeStyle(Color.clear))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(adbViewModel.selectedDevice.serial == device.serial ? LiquidGlassTheme.stroke : Color.clear, lineWidth: 1)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 220)
            }
        }
        .padding(10)
        .background(LiquidGlassTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                .stroke(LiquidGlassTheme.secondaryStroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
        .shadow(color: LiquidGlassTheme.secondaryShadow, radius: 8, y: 3)
    }

    private var currentDevice: DeviceInfo {
        switch mode {
        case .adb:
            return adbViewModel.selectedDevice
        case .fastboot:
            return fastbootViewModel.selectedDevice
        case .edl:
            return edlViewModel.selectedDevice
        }
    }

    private func adbStateText(for state: String) -> String {
        switch state {
        case "device":
            return "在线"
        case "offline":
            return "离线"
        case "unauthorized":
            return "未授权"
        default:
            return state
        }
    }
}
