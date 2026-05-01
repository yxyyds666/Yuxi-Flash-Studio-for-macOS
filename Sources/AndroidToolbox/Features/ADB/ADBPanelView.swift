import SwiftUI

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel
    private let rebootColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                headerRow
                deviceListSection
                rebootSection
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
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    private var headerRow: some View {
        HStack {
            Text("ADB")
                .font(.largeTitle.bold())
            Spacer()
            if viewModel.isAutoRefreshing {
                Label("实时刷新中", systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Button("刷新设备") {
                viewModel.refreshDevices()
            }
        }
    }

    private var deviceListSection: some View {
        GroupBox("设备列表") {
            VStack(spacing: 8) {
                if viewModel.devices.isEmpty {
                    Text("未检测到设备")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                } else {
                    ForEach(viewModel.devices) { device in
                        deviceRow(device)
                    }
                }
            }
        }
    }

    private var rebootSection: some View {
        GroupBox("快速重启") {
            LazyVGrid(columns: rebootColumns, spacing: 10) {
                ForEach(viewModel.rebootActions) { action in
                    rebootTile(for: action)
                }
            }
        }
    }

    private func deviceRow(_ device: DeviceInfo) -> some View {
        Button {
            viewModel.selectDevice(device)
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(device.isOnline ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.model)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(device.serial)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(stateText(for: device.state))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected(device) ? LiquidGlassTheme.cardBackground : AnyShapeStyle(Color.clear))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected(device) ? LiquidGlassTheme.stroke : Color.clear, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func rebootTile(for action: ADBRebootAction) -> some View {
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

    private func isSelected(_ device: DeviceInfo) -> Bool {
        viewModel.selectedDevice.serial == device.serial
    }

    private func stateText(for state: String) -> String {
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
