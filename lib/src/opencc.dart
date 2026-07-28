import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../flutter_opencc.dart';
import 'native/library.dart';
import 'opencc_config.dart';
import 'opencc_exception.dart';

/// High-level Dart API for the OpenCC Chinese text converter.
///
/// Usage:
/// ```dart
/// final converter = OpenCC(OpenCCConfig.s2t, dataDir: '/path/to/openccdata');
/// final result = converter.convert('鼠标');
/// print(result); // 滑鼠
/// converter.dispose();
/// ```
class OpenCC {
  final OpenCCConfig _config;
  final String _dataDir;
  Pointer<Void>? _nativeHandle;
  bool _disposed = false;

  /// Create an OpenCC converter.
  ///
  /// [config] specifies the conversion direction (e.g., S2T, T2S).
  /// [dataDir] is the absolute path to the directory containing OpenCC dictionary
  ///   data files (.ocd2, .json configuration files).
  ///
  /// Throws [OpenCCException] if initialization fails.
  OpenCC(this._config, {required String dataDir}) : _dataDir = dataDir {
    _init();
  }

  void _init() {
    if (!OpenCCNativeLibrary.isInitialized) {
      OpenCCNativeLibrary.initialize();
    }

    final configPath = _config.configFile.toNativeUtf8();
    final dataDirNative = _dataDir.toNativeUtf8();
    final errorOut = calloc<Pointer<Utf8>>();

    try {
      _nativeHandle = OpenCCNativeLibrary.createConverter(
          configPath, dataDirNative, errorOut);

      if (_nativeHandle == nullptr) {
        final errorMsg = errorOut.value != nullptr
            ? errorOut.value.toDartString()
            : 'Unknown error';
        // Free error string if set
        if (errorOut.value != nullptr) {
          OpenCCNativeLibrary.freeString(errorOut.value);
        }
        throw OpenCCException(
          'Failed to create converter for ${_config.name}: $errorMsg',
          code: 2,
        );
      }
    } finally {
      calloc.free(configPath);
      calloc.free(dataDirNative);
      calloc.free(errorOut);
    }
  }

  /// Convert [input] text from one Chinese variant to another.
  ///
  /// Returns the converted string.
  ///
  /// Throws [OpenCCException] if conversion fails or the converter is disposed.
  String convert(String input) {
    _ensureNotDisposed();

    if (input.isEmpty) return '';

    final inputNative = input.toNativeUtf8();
    final errorOut = calloc<Pointer<Utf8>>();

    try {
      final resultPtr = OpenCCNativeLibrary.convertText(
          _nativeHandle!, inputNative, errorOut);

      if (resultPtr == nullptr) {
        final errorMsg = errorOut.value != nullptr
            ? errorOut.value.toDartString()
            : 'Conversion failed';
        if (errorOut.value != nullptr) {
          OpenCCNativeLibrary.freeString(errorOut.value);
        }
        throw OpenCCException(errorMsg, code: 3);
      }

      final result = resultPtr.toDartString();
      OpenCCNativeLibrary.freeString(resultPtr);
      return result;
    } finally {
      calloc.free(inputNative);
      calloc.free(errorOut);
    }
  }

  /// The [OpenCCConfig] for this converter instance.
  OpenCCConfig get config => _config;

  /// The data directory path.
  String get dataDir => _dataDir;

  /// Whether this converter has been disposed.
  bool get isDisposed => _disposed;

  /// Release the native converter resources.
  ///
  /// After calling this, the converter must not be used.
  void dispose() {
    if (!_disposed && _nativeHandle != nullptr) {
      OpenCCNativeLibrary.destroyConverter(_nativeHandle!);
      _nativeHandle = nullptr;
      _disposed = true;
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw OpenCCException('Converter has been disposed');
    }
  }
}

/// Convenience class for one-shot conversions without managing converter lifecycle.
///
/// Useful when you only need to convert a few strings.
class OpenCCSimple {
  /// Convert [text] from one Chinese variant to another in one shot.
  ///
  /// [config] specifies the conversion direction.
  /// [dataDir] is the absolute path to the OpenCC dictionary data directory.
  ///
  /// Example:
  /// ```dart
  /// final result = OpenCCSimple.convert('鼠标', OpenCCConfig.s2t, dataDir: '/path/to/data');
  /// ```
  static String convert(String text, OpenCCConfig config,
      {required String dataDir}) {
    final converter = OpenCC(config, dataDir: dataDir);
    try {
      return converter.convert(text);
    } finally {
      converter.dispose();
    }
  }

  /// Convert multiple texts in batch using a single converter instance.
  ///
  /// More efficient than [convert] when processing many strings.
  static List<String> convertAll(List<String> texts, OpenCCConfig config,
      {required String dataDir}) {
    if (texts.isEmpty) return [];
    final converter = OpenCC(config, dataDir: dataDir);
    try {
      return texts.map((t) => converter.convert(t)).toList();
    } finally {
      converter.dispose();
    }
  }
}
