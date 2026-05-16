import SwiftUI

enum ADBPanelRoute: Hashable {
    case home
    case fileManager
}

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel
    @State private var route: ADBPanelRoute = .home

    private let rebootColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            switch route {
            case .home:
                homeContent
            case .fileManager:
                fileManagementSection
            }
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
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
        .onChange(of: route) { _, newRoute in
            if newRoute == .fileManager {
                viewModel.prepareFileManager()
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 12) {
            if route != .home {
                Button {
                    route = .home
                } label: {
                    Label("返回", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(titleForRoute(route))
                    .font(.largeTitle.bold())

                if route == .home {
                    Text("ADB 主界面")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

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

    private var homeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                rebootSection

                featureEntrySection

                deviceListSection
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private var featureEntrySection: some View {
        GroupBox("ADB 功能") {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    route = .fileManager
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.title3)
                            .foregroundStyle(Color.yellow)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("文件管理")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("浏览本地与设备目录，并执行 Push / Pull")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(LiquidGlassTheme.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var fileManagementSection: some View {
        HStack(alignment: .top, spacing: 12) {
            fileColumn(
                title: "本地文件",
                currentPath: viewModel.localCurrentPath,
                entries: viewModel.localEntries,
                selectedPath: viewModel.selectedLocalPath,
                onOpenParent: viewModel.openLocalParent,
                onOpenDirectory: viewModel.openLocalDirectory,
                onSelectEntry: viewModel.selectLocalEntry
            )

            transferControlSection
                .frame(width: 190)

            fileColumn(
                title: "设备文件",
                currentPath: viewModel.remoteCurrentPath,
                entries: viewModel.remoteEntries,
                selectedPath: viewModel.selectedRemotePath,
                onOpenParent: viewModel.openRemoteParent,
                onOpenDirectory: viewModel.openRemoteDirectory,
                onSelectEntry: viewModel.selectRemoteEntry
            )
        }
        .frame(maxHeight: .infinity)
    }

    private func fileColumn(
        title: String,
        currentPath: String,
        entries: [ADBFileEntry],
        selectedPath: String,
        onOpenParent: @escaping () -> Void,
        onOpenDirectory: @escaping (ADBFileEntry) -> Void,
        onSelectEntry: @escaping (ADBFileEntry) -> Void
    ) -> some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Button("上一级") {
                        onOpenParent()
                    }
                    .buttonStyle(.bordered)

                    Text(currentPath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                if entries.isEmpty {
                    Text("当前目录为空")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(entries) { entry in
                                Button {
                                    if entry.isDirectory {
                                        onOpenDirectory(entry)
                                    } else {
                                        onSelectEntry(entry)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: entry.isDirectory ? "folder.fill" : "doc.fill")
                                            .foregroundStyle(entry.isDirectory ? Color.yellow : Color.blue)
                                        Text(entry.name)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(selectedPath == entry.path ? LiquidGlassTheme.cardBackground : AnyShapeStyle(Color.clear))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(selectedPath == entry.path ? LiquidGlassTheme.stroke : Color.clear, lineWidth: 1)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var transferControlSection: some View {
        GroupBox("传输") {
            VStack(spacing: 12) {
                Button("选择本地目录") {
                    viewModel.pickLocalDirectory()
                }
                .buttonStyle(.bordered)

                Button("刷新设备目录") {
                    viewModel.refreshRemoteDirectory()
                }
                .buttonStyle(.bordered)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("本地选中")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.selectedLocalPath.isEmpty ? "未选择" : viewModel.selectedLocalPath)
                        .font(.caption2)
                        .lineLimit(2)
                        .truncationMode(.middle)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("设备选中")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.selectedRemotePath.isEmpty ? "未选择" : viewModel.selectedRemotePath)
                        .font(.caption2)
                        .lineLimit(2)
                        .truncationMode(.middle)
                }

                Divider()

                Button("Push 到设备 →") {
                    viewModel.pushSelected()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canPushSelected)

                Button("← Pull 到本地") {
                    viewModel.pullSelected()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canPullSelected)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity)
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

    private func titleForRoute(_ route: ADBPanelRoute) -> String {
        switch route {
        case .home:
            return "ADB"
        case .fileManager:
            return "ADB · 文件管理"
        }
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
