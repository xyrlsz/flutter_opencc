/*
 * flutter_opencc - Flutter FFI bridge for Open Chinese Convert (OpenCC)
 *
 * This file provides a C-compatible wrapper around OpenCC's C++ API,
 * with thread-safe error handling, converter caching, and result caching.
 * Uses the same pattern as android-opencc's chineseconverter.cpp:
 *   - opencc::Config + opencc::ConverterPtr for converter creation
 *   - XXH3_64bits for fast hash-based cache keys
 *   - LRUCache for result caching
 */

#include "opencc_bridge.h"
#include "OpenCC/src/Config.hpp"
#include "OpenCC/src/Converter.hpp"
#include "LRUCache.h"

#include <string>
#include <unordered_map>
#include <shared_mutex>
#include <cstring>

// ============================================================
// Thread-safe error handling
// ============================================================

static thread_local std::string tls_error_msg;

static void set_error(const char* msg) {
    tls_error_msg = msg ? msg : "";
}

static const char* get_error() {
    return tls_error_msg.c_str();
}

// ============================================================
// Converter handle (opaque, for Dart FFI)
// ============================================================

struct OpenCCConverter {
    opencc::ConverterPtr ptr;
    uint64_t pathHash;  // XXH3_64bits of fullPath for cache key
};

// ============================================================
// Global converter & result cache (thread-safe)
// Based on chineseconverter.cpp pattern
// ============================================================

struct ConverterEntry {
    opencc::ConverterPtr converter;
    uint64_t pathHash;
};

struct GlobalCache {
    std::unordered_map<std::string, ConverterEntry> converterMap;
    mutable std::shared_mutex converterMtx;

    // LRU result cache: 8192 entries, XXH3_64bits hash key
    LRUCache<uint64_t, CacheEntry> resultCache{8192};

    ConverterEntry getOrCreate(const std::string& fullPath) {
        // Fast path: shared_lock for concurrent reads
        {
            std::shared_lock<std::shared_mutex> lock(converterMtx);
            auto it = converterMap.find(fullPath);
            if (it != converterMap.end()) {
                return it->second;
            }
        }

        // Slow path: unique_lock for exclusive write
        std::unique_lock<std::shared_mutex> lock(converterMtx);
        auto it = converterMap.find(fullPath);
        if (it != converterMap.end()) {
            return it->second;
        }

        opencc::Config config;
        opencc::ConverterPtr converter = config.NewFromFile(fullPath);

        uint64_t pathHash = XXH3_64bits(fullPath.data(), fullPath.size());
        ConverterEntry entry = {converter, pathHash};
        converterMap[fullPath] = entry;
        return entry;
    }

    std::string convertWithCache(const ConverterEntry& entry, const std::string& text) {
        // XOR two independent hashes: zero-allocation, no string concatenation
        uint64_t key = entry.pathHash ^ XXH3_64bits(text.data(), text.size());

        // Fast cache lookup (shared_lock, concurrent reads)
        auto cached = resultCache.get(key);
        if (!cached.value.empty() && cached.keyStr == text) {
            return cached.value;
        }

        std::string result = entry.converter->Convert(text);

        // Cache result (max 64KB, covers most use cases)
        if (!result.empty() && result.length() < 65536) {
            resultCache.put(key, {text, result});
        }
        return result;
    }
};

static GlobalCache& GetGlobalCache() {
    static GlobalCache instance;
    return instance;
}

// ============================================================
// C API Implementation
// ============================================================

extern "C" {

__attribute__((visibility("default")))
__attribute__((used))
OpenCCConverter* opencc_create(const char* configPath, const char* dataDir, char** errorOut) {
    if (!configPath) {
        const char* msg = "configPath is null";
        set_error(msg);
        if (errorOut) *errorOut = strdup(msg);
        return nullptr;
    }

    // Build full path: if dataDir is given and configPath is a simple filename,
    // prepend dataDir to form the absolute config path
    std::string fullPath;
    {
        std::string cfg(configPath);
        if (dataDir && dataDir[0] != '\0' &&
            cfg.find('/') == std::string::npos &&
            cfg.find('\\') == std::string::npos) {
            fullPath = dataDir;
            if (!fullPath.empty() && fullPath.back() != '/' && fullPath.back() != '\\') {
                fullPath += '/';
            }
            fullPath += cfg;
        } else {
            fullPath = cfg;
        }
    }

    try {
        ConverterEntry entry = GetGlobalCache().getOrCreate(fullPath);
        auto* handle = new OpenCCConverter();
        handle->ptr = entry.converter;
        handle->pathHash = entry.pathHash;
        return handle;
    } catch (const std::exception& e) {
        set_error(e.what());
        if (errorOut) *errorOut = strdup(e.what());
        return nullptr;
    }
}

__attribute__((visibility("default")))
__attribute__((used))
char* opencc_convert(OpenCCConverter* converter, const char* input, char** errorOut) {
    if (!converter) {
        const char* msg = "converter is null";
        set_error(msg);
        if (errorOut) *errorOut = strdup(msg);
        return nullptr;
    }
    if (!input) {
        const char* msg = "input is null";
        set_error(msg);
        if (errorOut) *errorOut = strdup(msg);
        return nullptr;
    }

    try {
        // Build temporary entry for cache lookup
        ConverterEntry entry = {converter->ptr, converter->pathHash};
        std::string result = GetGlobalCache().convertWithCache(entry, input);

        char* out = static_cast<char*>(malloc(result.size() + 1));
        if (!out) {
            const char* msg = "memory allocation failed";
            set_error(msg);
            if (errorOut) *errorOut = strdup(msg);
            return nullptr;
        }
        std::memcpy(out, result.data(), result.size());
        out[result.size()] = '\0';
        return out;
    } catch (const std::exception& e) {
        set_error(e.what());
        if (errorOut) *errorOut = strdup(e.what());
        return nullptr;
    }
}

__attribute__((visibility("default")))
__attribute__((used))
void opencc_destroy(OpenCCConverter* converter) {
    delete converter;
    // Underlying opencc::ConverterPtr is managed by GlobalCache
    // Multiple opencc_create with same path share the same ConverterEntry
}

__attribute__((visibility("default")))
__attribute__((used))
void opencc_free_string(char* str) {
    free(str);
}

__attribute__((visibility("default")))
__attribute__((used))
char* opencc_version() {
    const char* ver = OPENCC_VERSION;
    if (!ver || ver[0] == '\0') ver = "unknown";
    char* out = static_cast<char*>(malloc(strlen(ver) + 1));
    if (out) {
        std::strcpy(out, ver);
    }
    return out;
}

} // extern "C"
