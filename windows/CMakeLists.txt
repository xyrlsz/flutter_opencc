# Windows CMake build for flutter_opencc native library
# Sources match android-opencc Android.mk.
cmake_minimum_required(VERSION 3.12)
project(flutter_opencc CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# OpenCC compile flags
add_definitions(-DOPENCC_ENABLE_DARTS)

# Root source directory
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src")

# Include paths for OpenCC and its dependencies
include_directories(
    ${SRC_DIR}
    ${SRC_DIR}/OpenCC/src
    ${SRC_DIR}/OpenCC/deps/darts-clone-0.32h/include
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/include
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib
    ${SRC_DIR}/OpenCC/deps/rapidjson-1.1.0
    ${SRC_DIR}/xxHash
)

# ---- OpenCC source files ----
set(OPENCC_SOURCES
    ${SRC_DIR}/OpenCC/src/BinaryDict.cpp
    ${SRC_DIR}/OpenCC/src/Config.cpp
    ${SRC_DIR}/OpenCC/src/Conversion.cpp
    ${SRC_DIR}/OpenCC/src/ConversionChain.cpp
    ${SRC_DIR}/OpenCC/src/Converter.cpp
    ${SRC_DIR}/OpenCC/src/DartsDict.cpp
    ${SRC_DIR}/OpenCC/src/Dict.cpp
    ${SRC_DIR}/OpenCC/src/DictConverter.cpp
    ${SRC_DIR}/OpenCC/src/DictEntry.cpp
    ${SRC_DIR}/OpenCC/src/DictGroup.cpp
    ${SRC_DIR}/OpenCC/src/Lexicon.cpp
    ${SRC_DIR}/OpenCC/src/MarisaDict.cpp
    ${SRC_DIR}/OpenCC/src/MaxMatchSegmentation.cpp
    ${SRC_DIR}/OpenCC/src/PhraseExtract.cpp
    ${SRC_DIR}/OpenCC/src/PipelineConverter.cpp
    ${SRC_DIR}/OpenCC/src/SerializedValues.cpp
    ${SRC_DIR}/OpenCC/src/SerializableDict.cpp
    ${SRC_DIR}/OpenCC/src/Segmentation.cpp
    ${SRC_DIR}/OpenCC/src/SimpleConverter.cpp
    ${SRC_DIR}/OpenCC/src/SingleStageConverter.cpp
    ${SRC_DIR}/OpenCC/src/TextDict.cpp
    ${SRC_DIR}/OpenCC/src/UTF8StringSlice.cpp
    ${SRC_DIR}/OpenCC/src/UTF8Util.cpp
    ${SRC_DIR}/OpenCC/src/PluginSegmentation.cpp
    ${SRC_DIR}/OpenCC/src/PrefixMatch.cpp
    ${SRC_DIR}/OpenCC/src/ResourceProvider.cpp
)

# ---- Marisa source files ----
set(MARISA_SOURCES
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/trie.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/agent.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/reader.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/writer.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/mapper.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/trie/louds-trie.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/trie/tail.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/vector/bit-vector.cc
    ${SRC_DIR}/OpenCC/deps/marisa-0.3.1/lib/marisa/keyset.cc
)

# ---- xxHash ----
set(XXHASH_SOURCES
    ${SRC_DIR}/xxHash/xxhash.c
)

# ---- Flutter bridge ----
set(BRIDGE_SOURCES
    ${SRC_DIR}/opencc_bridge.cpp
    ${SRC_DIR}/LRUCache.cpp
)

# Build the shared library
add_library(flutter_opencc SHARED
    ${BRIDGE_SOURCES}
    ${OPENCC_SOURCES}
    ${MARISA_SOURCES}
    ${XXHASH_SOURCES}
)
