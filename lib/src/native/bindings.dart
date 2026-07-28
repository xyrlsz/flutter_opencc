import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// FFI type definitions for the OpenCC native bridge.
///
/// Matches the C API declared in `src/opencc_bridge.h`.

// Opaque pointer type for OpenCCConverter handle
typedef OpenCCConverterNative = Pointer<Void>;

// --- Function type definitions ---

// OpenCCConverter* opencc_create(const char* configPath, const char* dataDir, char** errorOut);
typedef OpenCCCreateNative = Pointer<Void> Function(Pointer<Utf8> configPath,
    Pointer<Utf8> dataDir, Pointer<Pointer<Utf8>> errorOut);
typedef OpenCCCreateDart = Pointer<Void> Function(Pointer<Utf8> configPath,
    Pointer<Utf8> dataDir, Pointer<Pointer<Utf8>> errorOut);

// char* opencc_convert(OpenCCConverter* converter, const char* input, char** errorOut);
typedef OpenCCConvertNative = Pointer<Utf8> Function(Pointer<Void> converter,
    Pointer<Utf8> input, Pointer<Pointer<Utf8>> errorOut);
typedef OpenCCConvertDart = Pointer<Utf8> Function(Pointer<Void> converter,
    Pointer<Utf8> input, Pointer<Pointer<Utf8>> errorOut);

// void opencc_destroy(OpenCCConverter* converter);
typedef OpenCCDestroyNative = Void Function(Pointer<Void> converter);
typedef OpenCCDestroyDart = void Function(Pointer<Void> converter);

// void opencc_free_string(char* str);
typedef OpenCCFreeStringNative = Void Function(Pointer<Utf8> str);
typedef OpenCCFreeStringDart = void Function(Pointer<Utf8> str);

// char* opencc_version();
typedef OpenCCVersionNative = Pointer<Utf8> Function();
typedef OpenCCVersionDart = Pointer<Utf8> Function();
