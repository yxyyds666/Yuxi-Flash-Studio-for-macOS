import SwiftUI

enum ADBPanelRoute: Hashable {
    case home
    case fileManager
    case apkInstall
}

struct ADBPanelView: View {
    @Bindable var viewModel: ADBViewModel
    @State private var route: ADBPanelRoute = .home

    private let rebootColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private let featureColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            switch route {
            case .home:
                homeContent
            case .fileManager:
                fileManagementSection
            case .apkInstall:
                apkInstallSection
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

                switch route {
                case .home:
                    Text("ADB 主界面")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .fileManager:
                    Text("浏览与传输设备文件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .apkInstall:
                    Text("选择 APK 文件并安装到设备")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if viewModel.isAutoRefreshing {
                Label("搜索设备中", systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Button("刷新设备") {
                viewModel.refreshDevices()
            }
        }
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            rebootSection

            featureEntrySection

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var featureEntrySection: some View {
        GroupBox("ADB 功能") {
            LazyVGrid(columns: featureColumns, spacing: 12) {
                featureTile(
                    title: "文件管理",
                    subtitle: "可视化文件浏览",
                    systemImage: "folder.fill",
                    tint: .yellow,
                    action: { route = .fileManager }
                )

                featureTile(
                    title: "APK 安装",
                    subtitle: "选择安装包并执行安装",
                    systemImage: "square.and.arrow.down.fill",
                    tint: .green,
                    action: { route = .apkInstall }
                )
            }
        }
    }

    private func featureTile(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(tint)

                Spacer(minLength: 0)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
            .padding(12)
            .background(LiquidGlassTheme.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: LiquidGlassTheme.shadow, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var apkInstallSection: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: viewModel.apkPath)

                Text("安装 APK")
                    .font(.title2.bold())

                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "app.fill")
                            .foregroundStyle(.secondary)
                        TextField("点击右侧按钮选择 APK 文件", text: $viewModel.apkPath)
                            .textFieldStyle(.roundedBorder)
                            .disabled(true)

                        Button("浏览…") {
                            viewModel.pickApkFile()
                        }
                        .buttonStyle(.bordered)
                    }

                    if !viewModel.apkPath.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                            Text(URL(fileURLWithPath: viewModel.apkPath).lastPathComponent)
                                .font(.subheadline.weight(.medium))
                            Text(byteCountFormatted(URL(fileURLWithPath: viewModel.apkPath)))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button(action: { viewModel.installApk() }) {
                        Label("安装", systemImage: "arrow.down.to.line")
                            .frame(maxWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(viewModel.apkPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(40)
            .background(LiquidGlassTheme.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous)
                    .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius, style: .continuous))
            .shadow(color: LiquidGlassTheme.shadow, radius: 8, y: 2)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func byteCountFormatted(_ url: URL) -> String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return "" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
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
                Toggle(isOn: Binding(
                    get: { viewModel.isRootModeEnabled },
                    set: { viewModel.setRootModeEnabled($0) }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Root 浏览")
                            .font(.subheadline.weight(.semibold))
                        Text("开启后通过 su 浏览 / 与受保护目录")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)

                Text("以 Root 权限浏览")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

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
            .shadow(color: LiquidGlassTheme.shadow, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func titleForRoute(_ route: ADBPanelRoute) -> String {
        switch route {
        case .home:
            return "ADB"
        case .fileManager:
            return "ADB · 文件管理"
        case .apkInstall:
            return "ADB · APK 安装"
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
