/// Flutter OpenCC — A Dart FFI binding for Open Chinese Convert (OpenCC).
///
/// This library provides conversion between:
/// - Simplified Chinese (简体中文)
/// - Standard Traditional Chinese (标准繁体)
/// - Taiwanese Traditional Chinese (台湾正体)
/// - Hong Kong Traditional Chinese (香港繁体)
/// - Japanese Kyūjitai / Shinjitai (日文新旧字体)
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter_opencc/flutter_opencc.dart';
///
/// // One-shot conversion:
/// final result = OpenCCSimple.convert(
///   '鼠标',
///   OpenCCConfig.s2t,
///   dataDir: '/path/to/openccdata',
/// );
/// print(result); // 滑鼠
///
/// // Reusable converter (for multiple conversions):
/// final converter = OpenCC(OpenCCConfig.s2t, dataDir: '/path/to/openccdata');
/// print(converter.convert('鼠标')); // 滑鼠
/// print(converter.convert('分辨率')); // 解析度
/// converter.dispose();
/// ```
library flutter_opencc;

export 'src/opencc_config.dart';
export 'src/opencc_exception.dart';
export 'src/opencc.dart';
