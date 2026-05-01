import SwiftUI

struct AppShellView: View {
    @State private var mode: ToolboxMode = .adb
    @State private var adbViewModel = ADBViewModel()
    @State private var fastbootViewModel = FastbootViewModel()
    @State private var edlViewModel = EDLViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.24), Color.purple.opacity(0.12), Color.black.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                HeaderView()
                HStack(alignment: .top, spacing: 12) {
                    mainPanel
                    rightSidebar
                        .frame(width: 300)
                }
            }
            .padding(14)
            .background(LiquidGlassTheme.panelBackground)
            .overlay {
                RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius + 4, style: .continuous)
                    .stroke(LiquidGlassTheme.stroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: LiquidGlassTheme.cornerRadius + 4, style: .continuous))
            .shadow(color: LiquidGlassTheme.shadow, radius: 24, y: 12)
            .padding(10)
        }
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
        VStack(spacing: 12) {
            DeviceStatusCardView(device: currentDevice)
            ModeSidebarView(mode: $mode)
            Spacer()
        }
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
}
