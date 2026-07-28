#ifndef FLUTTER_OPENCC_BRIDGE_H
#define FLUTTER_OPENCC_BRIDGE_H

#include <cstdint>
#include <cstddef>

// C-compatible API for Dart FFI
// All functions use extern "C" to prevent name mangling

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle to an OpenCC converter instance
typedef struct OpenCCConverter OpenCCConverter;

/**
 * Create an OpenCC converter instance.
 * @param configPath Configuration file name (e.g., "s2t.json") or full path
 * @param dataDir    Absolute path to the dictionary data directory (optional, can be NULL)
 * @param errorOut   Optional output for error message (caller must free with opencc_free_string)
 * @return Opaque handle, or NULL on failure
 */
__attribute__((visibility("default")))
__attribute__((used))
OpenCCConverter* opencc_create(const char* configPath, const char* dataDir, char** errorOut);

/**
 * Convert text using the given converter.
 * @param converter  Converter handle returned by opencc_create
 * @param input      Input UTF-8 text
 * @param errorOut   Optional output for error message (caller must free with opencc_free_string)
 * @return Converted UTF-8 string, or NULL on failure (caller must free with opencc_free_string)
 */
__attribute__((visibility("default")))
__attribute__((used))
char* opencc_convert(OpenCCConverter* converter, const char* input, char** errorOut);

/**
 * Destroy a converter instance and free its resources.
 * @param converter Converter handle to destroy (safe to pass NULL)
 */
__attribute__((visibility("default")))
__attribute__((used))
void opencc_destroy(OpenCCConverter* converter);

/**
 * Free a string allocated by the library.
 * @param str String to free (safe to pass NULL)
 */
__attribute__((visibility("default")))
__attribute__((used))
void opencc_free_string(char* str);

/**
 * Get the version string of the OpenCC library.
 * @return Version string (caller must free with opencc_free_string)
 */
__attribute__((visibility("default")))
__attribute__((used))
char* opencc_version();

#ifdef __cplusplus
}
#endif

#endif // FLUTTER_OPENCC_BRIDGE_H
