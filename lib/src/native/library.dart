import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'bindings.dart';

/// Loads and manages the native OpenCC dynamic library.
///
/// Handles platform-specific library loading logic.
class OpenCCNativeLibrary {
  static DynamicLibrary? _lib;
  static bool _initialized = false;

  // Native function pointers (lazily resolved)
  static OpenCCCreateDart? _create;
  static OpenCCConvertDart? _convert;
  static OpenCCDestroyDart? _destroy;
  static OpenCCFreeStringDart? _freeString;
  static OpenCCVersionDart? _version;

  /// Initialize the native library. Must be called before any other operations.
  static void initialize() {
    if (_initialized) return;

    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libflutter_opencc.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      _lib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('flutter_opencc.dll');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('libflutter_opencc.so');
    } else {
      throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}');
    }

    _resolveFunctions();
    _initialized = true;
  }

  static void _resolveFunctions() {
    _create = _lib!
        .lookup<NativeFunction<OpenCCCreateNative>>('opencc_create')
        .asFunction<OpenCCCreateDart>();

    _convert = _lib!
        .lookup<NativeFunction<OpenCCConvertNative>>('opencc_convert')
        .asFunction<OpenCCConvertDart>();

    _destroy = _lib!
        .lookup<NativeFunction<OpenCCDestroyNative>>('opencc_destroy')
        .asFunction<OpenCCDestroyDart>();

    _freeString = _lib!
        .lookup<NativeFunction<OpenCCFreeStringNative>>('opencc_free_string')
        .asFunction<OpenCCFreeStringDart>();

    _version = _lib!
        .lookup<NativeFunction<OpenCCVersionNative>>('opencc_version')
        .asFunction<OpenCCVersionDart>();
  }

  /// Whether the library has been initialized.
  static bool get isInitialized => _initialized;

  // --- Native method wrappers ---

  static Pointer<Void> createConverter(Pointer<Utf8> configPath,
      Pointer<Utf8> dataDir, Pointer<Pointer<Utf8>> errorOut) {
    return _create!(configPath, dataDir, errorOut);
  }

  static Pointer<Utf8> convertText(Pointer<Void> converter, Pointer<Utf8> input,
      Pointer<Pointer<Utf8>> errorOut) {
    return _convert!(converter, input, errorOut);
  }

  static void destroyConverter(Pointer<Void> converter) {
    _destroy!(converter);
  }

  static void freeString(Pointer<Utf8> str) {
    _freeString!(str);
  }

  static String getVersion() {
    final ptr = _version!();
    final result = ptr.toDartString();
    freeString(ptr);
    return result;
  }
}
