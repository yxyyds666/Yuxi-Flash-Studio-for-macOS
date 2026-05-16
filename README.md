# Yuxi Flash Studio for macOS

中文 | [English](#english)

---

## 中文

Yuxi Flash Studio 是一个面向 macOS 的安卓工具箱，集成 **ADB / Fastboot / Qualcomm EDL(9008)** 常用流程，目标是开箱即用。

### 功能特性（当前）

- ADB 一站式功能：设备管理、重启矩阵、文件管理、应用管理（安装/卸载）
- ADB 投屏：集成 `scrcpy`，支持分辨率/码率/FPS、全屏、置顶、禁音、只读控制等参数
- Fastboot 设备检测与基础控制
- Qualcomm EDL(9008) 入口（当前版本点击提示“开发中”，暂不开放）
- macOS 液态玻璃风格界面与统一日志面板

### scrcpy 依赖

ADB 投屏功能依赖本机已安装 `scrcpy`：

```bash
brew install scrcpy
```

### 运行环境

- macOS 15+
- Swift 6.2+

### 本地运行

```bash
swift build
swift run AndroidToolbox
```

### 测试

```bash
swift test
```

### 开源协议

本项目使用 **Apache-2.0** 协议，详见 `LICENSE`。

---

## English

Yuxi Flash Studio is a macOS Android toolbox that integrates common **ADB / Fastboot / Qualcomm EDL (9008)** workflows with an out-of-the-box experience.

### Features (Current)

- ADB all-in-one tools: device management, reboot matrix, file manager, app manager (install/uninstall)
- ADB screen mirroring via `scrcpy`, with configurable resolution/bitrate/FPS, fullscreen, always-on-top, no-audio, and read-only control
- Fastboot device detection and basic controls
- Qualcomm EDL (9008) entry is currently gated and marked as "in development"
- Liquid-glass styled macOS UI with unified runtime log panel

### scrcpy dependency

ADB screen mirroring requires `scrcpy` installed locally:

```bash
brew install scrcpy
```

### Requirements

- macOS 15+
- Swift 6.2+

### Run locally

```bash
swift build
swift run AndroidToolbox
```

### Tests

```bash
swift test
```

### License

This project is licensed under **Apache-2.0**. See `LICENSE` for details.
