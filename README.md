# Flutter OpenCC

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Flutter OpenCC** 是一个使用 Dart FFI 集成 [OpenCC (Open Chinese Convert)](https://github.com/BYVoid/OpenCC) 的 Flutter 插件，提供简繁转换及地区词汇转换能力。

## ✨ 特性

- 使用 **Dart FFI** 直接调用 OpenCC 原生 C/C++ 代码，性能卓越
- 支持 **16 种转换配置**（简繁、台湾正体、香港繁体、日文新旧字体）
- 跨平台支持：**Android、iOS、macOS、Windows、Linux**
- 内置 **Converter 缓存**，避免重复创建开销
- 线程安全，支持并发转换

## 📋 支持的转换类型

| 配置 | 说明 |
|------|------|
| `S2T` | 简体中文 → 标准繁体 |
| `T2S` | 标准繁体 → 简体中文 |
| `S2TW` | 简体中文 → 台湾正体 |
| `TW2S` | 台湾正体 → 简体中文 |
| `S2HK` | 简体中文 → 香港繁体 |
| `HK2S` | 香港繁体 → 简体中文 |
| `S2TWP` | 简体中文 → 台湾正体（含词汇） |
| `TW2SP` | 台湾正体 → 简体中文（含词汇） |
| `T2TW` | 标准繁体 → 台湾正体 |
| `TW2T` | 台湾正体 → 标准繁体 |
| `T2HK` | 标准繁体 → 香港繁体 |
| `HK2T` | 香港繁体 → 标准繁体 |
| `S2HKP` | 简体中文 → 香港繁体（含词汇） |
| `HK2SP` | 香港繁体 → 简体中文（含词汇） |
| `T2JP` | 日文旧字体 → 日文新字体 |
| `JP2T` | 日文新字体 → 日文旧字体 |

## 🚀 快速开始

### 1. 克隆仓库并初始化子模块

```bash
git clone https://github.com/xyrlsz/flutter_opencc.git
cd flutter_opencc
git submodule update --init --recursive
```

> **注意**：`git submodule update --init --recursive` 会拉取 `src/OpenCC` 和 `src/xxHash` 两个子模块，编译原生代码需要它们。

### 2. 添加依赖

在目标项目的 `pubspec.yaml` 中添加本地依赖：

```yaml
dependencies:
  flutter_opencc:
    path: ./flutter_opencc   # 指向你克隆下来的本地路径
```

> **提示**：`path` 依赖适合本地开发调试，修改源码后无需重新 `pub get`，`flutter pub get` 会自动链接。

如果你希望直接从 Git 引用（不 clone 到本地）：

```yaml
dependencies:
  flutter_opencc:
    git:
      url: https://github.com/xyrlsz/flutter_opencc.git
      ref: v1.0.0  # 可选：指定 tag / 分支 / commit
```

> **注意**：通过 git 依赖安装时，`pub get` **不会**自动拉取子模块（`src/OpenCC`、`src/xxHash`）。
> 如果仅使用预编译二进制，则无需关心；如需修改原生代码，请先手动 clone 并初始化子模块。

### 3. 使用（字典数据已内建）

本插件已将全部字典文件打包为 Flutter Package Asset，开箱即用：

```dart
import 'package:flutter_opencc/flutter_opencc.dart';

// 一行代码提取内建字典到本地文件系统（仅首次需要）
final dataDir = await OpenCCData.prepareData();

// 方式一：一次性转换（自动管理资源）
String result = OpenCCSimple.convert(
  '鼠标',
  OpenCCConfig.s2t,
  dataDir: dataDir,
);
print(result); // 滑鼠

// 方式二：复用 Converter 实例（批量转换时更高效）
final converter = OpenCC(OpenCCConfig.s2t, dataDir: dataDir);
print(converter.convert('鼠标'));       // 滑鼠
print(converter.convert('分辨率'));     // 解析度
converter.dispose();

// 方式三：批量转换
List<String> results = OpenCCSimple.convertAll(
  ['鼠标', '分辨率', '硅二极管'],
  OpenCCConfig.s2t,
  dataDir: dataDir,
);
```

> **注意**：`OpenCCData.prepareData()` 从 Flutter Asset Bundle 提取字典到系统临时目录（`{tempDir}/flutter_opencc_data/`），
> 已提取的文件会跳过以提高速度。如需指定存放目录，可传 `targetDir` 参数。

## 🏗 项目结构

```
flutter_opencc/
├── assets/
│   └── openccdata/                   # 📦 内建字典文件 (.ocd2 + .json)
├── lib/
│   ├── flutter_opencc.dart           # 库入口，导出公开 API
│   └── src/
│       ├── opencc.dart               # 核心 OpenCC 类
│       ├── opencc_config.dart        # 转换配置枚举
│       ├── opencc_exception.dart     # 异常类型
│       ├── data_loader.dart          # 字典数据提取工具（OpenCCData）
│       └── native/
│           ├── bindings.dart         # FFI 类型定义
│           └── library.dart          # 动态库加载
├── src/                              # ⚙️ 原生 C/C++ 源码
│   ├── opencc_bridge.h               # C API 头文件 (extern "C")
│   ├── opencc_bridge.cpp             # Dart FFI 桥接 (Config/Converter/LRUCache)
│   ├── LRUCache.h / LRUCache.cpp     # 线程安全 LRU 缓存
│   ├── OpenCC/                       # OpenCC 官方源代码 (git submodule)
│   │   ├── src/                      # 26 个 .cpp + 头文件
│   │   └── deps/                     # 依赖: darts-clone, marisa, rapidjson
│   └── xxHash/                       # xxHash 官方源代码 (git submodule)
├── dic_tools/                        # 🔧 字典生成工具
│   ├── CMakeLists.txt                # 从源码编译 opencc_dict
│   ├── generate_dicts.py             # 一键生成所有 .ocd2 字典
│   ├── generate_dicts.ps1            # PowerShell 包装脚本
│   ├── generate_dicts.sh             # Shell 包装脚本
│   └── README.md                     # 字典生成说明
├── android/
│   ├── CMakeLists.txt                # Android NDK CMake 构建
│   └── build.gradle                  # Android Gradle 配置
├── ios/
│   └── flutter_opencc.podspec        # iOS CocoaPods 配置
├── macos/
│   └── flutter_opencc.podspec        # macOS CocoaPods 配置
├── windows/
│   └── CMakeLists.txt                # Windows CMake 构建
├── linux/
│   └── CMakeLists.txt                # Linux CMake 构建
├── example/
│   └── lib/
│       └── main.dart                 # 示例应用（使用 OpenCCData.prepareData）
└── pubspec.yaml
```

## 🔧 编译要求

### Android
- Android NDK（推荐 r25+）
- CMake 3.12+

### iOS / macOS
- Xcode 14+
- CocoaPods

### Windows
- Visual Studio 2022（含 C++ 开发工具）
- CMake 3.12+

### Linux
- GCC 10+ 或 Clang 12+
- CMake 3.12+

## 📦 初始化子模块

本项目使用 Git Submodule 管理 OpenCC 和 xxHash 源码：

```bash
git submodule update --init --recursive
```

这将检出：
- `src/OpenCC` — BYVoid/OpenCC
- `src/xxHash` — Cyan4973/xxHash

## 📦 生成字典文件

字典源文件位于 `src/OpenCC/data/`，使用 `dic_tools` 生成 `.ocd2` 二进制字典：

```bash
# 安装 opencc CLI（需含 opencc_dict 工具）
scoop install opencc          # Windows
brew install opencc           # macOS
apt install opencc            # Debian/Ubuntu

# 生成字典
cd dic_tools
python3 generate_dicts.py
```

生成的字典和配置文件会输出到 `dic_tools/assets/openccdata/`，然后可复制到 `assets/openccdata/` 更新内建字典。

## 🔄 与 Platform Channel 方案的对比

| 特性 | Dart FFI（本方案） | Platform Channel |
|------|-------------------|-----------------|
| 性能 | 🏆 极高（直接调用） | 中等（序列化开销） |
| 代码复杂度 | 低 | 高（需 Java/ObjC 桥接） |
| 跨平台共享 | ✅ C++ 源码全平台共享 | ❌ 各平台单独实现 |
| 内存管理 | 手动（Dart 控制） | 自动（平台侧管理） |
| 适用场景 | 计算密集型、高频调用 | 平台 API 调用 |

## 📄 许可证

本项目基于 **MIT License** 开源。OpenCC 本身使用 Apache License 2.0。

## 🙏 致谢

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC) — 开源中文转换库
- [Cyan4973/xxHash](https://github.com/Cyan4973/xxHash) — 用于缓存的哈希计算
- [android-opencc](https://github.com/xyrlsz/android-opencc) — Android JNI 版 OpenCC（本项目的参考实现）