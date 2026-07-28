# Flutter OpenCC

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

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

### 1. 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_opencc:
    git:
      url: https://github.com/xyrlsz/flutter_opencc.git
```

### 2. 初始化 OpenCC 数据

OpenCC 需要字典数据文件（`.ocd2` 和 `.json` 配置文件）。你需要：

- **Android**: 将 `src/OpenCC/data/` 中的字典文件打包到 assets，首次使用时复制到应用文件目录
- **iOS/macOS**: 将字典文件添加到 Bundle Resources
- **Windows/Linux**: 将字典文件放置在应用可访问的路径

### 3. 使用

```dart
import 'package:flutter_opencc/flutter_opencc.dart';

// 方式一：一次性转换（自动管理资源）
String result = OpenCCSimple.convert(
  '鼠标',
  OpenCCConfig.s2t,
  dataDir: '/path/to/openccdata',
);
print(result); // 滑鼠

// 方式二：复用 Converter 实例（批量转换时更高效）
final converter = OpenCC(OpenCCConfig.s2t, dataDir: '/path/to/openccdata');
print(converter.convert('鼠标'));       // 滑鼠
print(converter.convert('分辨率'));     // 解析度
print(converter.convert('硅二极管'));   // 矽二極體
converter.dispose();

// 方式三：批量转换
List<String> results = OpenCCSimple.convertAll(
  ['鼠标', '分辨率', '硅二极管'],
  OpenCCConfig.s2t,
  dataDir: '/path/to/openccdata',
);
```

## 🏗 项目结构

```
flutter_opencc/
├── lib/
│   ├── flutter_opencc.dart           # 库入口，导出公开 API
│   └── src/
│       ├── opencc.dart               # 核心 OpenCC 类
│       ├── opencc_config.dart        # 转换配置枚举
│       ├── opencc_exception.dart     # 异常类型
│       └── native/
│           ├── bindings.dart         # FFI 类型定义
│           └── library.dart          # 动态库加载
├── src/                              # ← 原生 C/C++ 源码
│   ├── opencc_bridge.h               # C API 头文件 (extern "C")
│   ├── opencc_bridge.cpp             # Dart FFI 桥接 (Config/Converter/LRUCache)
│   ├── LRUCache.h                    # 线程安全 LRU 缓存 (来自 android-opencc)
│   ├── LRUCache.cpp
│   ├── OpenCC/                       # OpenCC 官方源代码 (BYVoid/OpenCC)
│   │   ├── src/                      # 26 个 .cpp + 头文件
│   │   └── deps/                     # 依赖: darts-clone, marisa, rapidjson
│   └── xxHash/                       # xxHash 官方源代码
│       ├── xxhash.h
│       ├── xxh3.h
│       └── xxhash.c
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
│       └── main.dart                 # 示例应用
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

## 📦 准备 OpenCC 源码

将 OpenCC 和 xxHash 官方源码放入 `src/` 目录：

```bash
# 从本地 android-opencc 项目复制（推荐）
cp -r <path>/android-opencc/lib-opencc-android/src/main/jni/OpenCC   src/
cp -r <path>/android-opencc/lib-opencc-android/src/main/jni/xxHash   src/

# 或从官方仓库克隆
git clone https://github.com/BYVoid/OpenCC.git   src/OpenCC
git clone https://github.com/Cyan4973/xxHash.git  src/xxHash
```

确保目录结构完整：
- `src/OpenCC/src/` — 所有 `.cpp`/`.hpp` 文件
- `src/OpenCC/deps/` — darts-clone、marisa、rapidjson
- `src/xxHash/xxhash.h`、`xxh3.h`、`xxhash.c`

## 📦 初始化字典数据

编译后，需要在运行时提供 OpenCC 字典数据文件：

### Android 示例（从 assets 复制）

```dart
import 'package:flutter/services.dart';
import 'dart:io';

Future<String> initOpenCCData() async {
  final appDir = await getApplicationDocumentsDirectory();
  final dataDir = Directory('${appDir.path}/openccdata');
  
  if (!dataDir.exists()) {
    dataDir.createSync();
    // 从 assets 复制字典文件
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final assets = manifest.split('\n')
        .where((line) => line.startsWith('assets/openccdata/'))
        .toList();
    for (final asset in assets) {
      final fileName = asset.split('/').last.trim().replaceAll('"', '');
      final bytes = await rootBundle.load('assets/openccdata/$fileName');
      final file = File('${dataDir.path}/$fileName');
      await file.writeAsBytes(bytes.buffer.asUint8List());
    }
  }
  return dataDir.path;
}
```

## 🔄 与 Platform Channel 方案的对比

| 特性 | Dart FFI（本方案） | Platform Channel |
|------|-------------------|-----------------|
| 性能 | 🏆 极高（直接调用） | 中等（序列化开销） |
| 代码复杂度 | 低 | 高（需 Java/ObjC 桥接） |
| 跨平台共享 | ✅ C++ 源码全平台共享 | ❌ 各平台单独实现 |
| 内存管理 | 手动（Dart 控制） | 自动（平台侧管理） |
| 适用场景 | 计算密集型、高频调用 | 平台 API 调用 |

## 📄 许可证

本项目基于 **Apache License 2.0** 开源。OpenCC 本身使用 Apache License 2.0。

## 🙏 致谢

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC) — 开源中文转换库
- [android-opencc](https://github.com/xyrlsz/android-opencc) — Android JNI 版 OpenCC（本项目的参考实现）
