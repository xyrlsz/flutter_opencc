#
# macOS podspec for flutter_opencc
#
Pod::Spec.new do |s|
  s.name             = 'flutter_opencc'
  s.version          = '1.0.0'
  s.summary          = 'Flutter FFI plugin for Open Chinese Convert (OpenCC)'
  s.description      = <<-DESC
  Flutter FFI plugin providing Chinese text conversion between Simplified Chinese,
  Traditional Chinese, and regional variants (Taiwan, Hong Kong, Japan).
                       DESC
  s.homepage         = 'https://github.com/xyrlsz/flutter_opencc'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'xyrlsz' => 'xyrlsz@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'

  # Root source directory
  src_dir = '../src'

  # OpenCC C++ source files (26 files matching Android.mk)
  s.source_files = [
    'Classes/**/*.{h,m,mm}',
    "#{src_dir}/opencc_bridge.cpp",
    "#{src_dir}/LRUCache.cpp",
    "#{src_dir}/OpenCC/src/BinaryDict.cpp",
    "#{src_dir}/OpenCC/src/Config.cpp",
    "#{src_dir}/OpenCC/src/Conversion.cpp",
    "#{src_dir}/OpenCC/src/ConversionChain.cpp",
    "#{src_dir}/OpenCC/src/Converter.cpp",
    "#{src_dir}/OpenCC/src/DartsDict.cpp",
    "#{src_dir}/OpenCC/src/Dict.cpp",
    "#{src_dir}/OpenCC/src/DictConverter.cpp",
    "#{src_dir}/OpenCC/src/DictEntry.cpp",
    "#{src_dir}/OpenCC/src/DictGroup.cpp",
    "#{src_dir}/OpenCC/src/Lexicon.cpp",
    "#{src_dir}/OpenCC/src/MarisaDict.cpp",
    "#{src_dir}/OpenCC/src/MaxMatchSegmentation.cpp",
    "#{src_dir}/OpenCC/src/PhraseExtract.cpp",
    "#{src_dir}/OpenCC/src/PipelineConverter.cpp",
    "#{src_dir}/OpenCC/src/SerializedValues.cpp",
    "#{src_dir}/OpenCC/src/SerializableDict.cpp",
    "#{src_dir}/OpenCC/src/Segmentation.cpp",
    "#{src_dir}/OpenCC/src/SimpleConverter.cpp",
    "#{src_dir}/OpenCC/src/SingleStageConverter.cpp",
    "#{src_dir}/OpenCC/src/TextDict.cpp",
    "#{src_dir}/OpenCC/src/UTF8StringSlice.cpp",
    "#{src_dir}/OpenCC/src/UTF8Util.cpp",
    "#{src_dir}/OpenCC/src/PluginSegmentation.cpp",
    "#{src_dir}/OpenCC/src/PrefixMatch.cpp",
    "#{src_dir}/OpenCC/src/ResourceProvider.cpp",
    # Marisa sources
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/trie.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/agent.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/reader.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/writer.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/io/mapper.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/trie/louds-trie.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/trie/tail.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/grimoire/vector/bit-vector.cc",
    "#{src_dir}/OpenCC/deps/marisa-0.3.1/lib/marisa/keyset.cc",
    # xxHash
    "#{src_dir}/xxHash/xxhash.c",
  ]

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_CPLUSPLUSFLAGS' => '-DOPENCC_ENABLE_DARTS -std=c++17',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => [
      '${PODS_TARGET_SRCROOT}/../src',
      '${PODS_TARGET_SRCROOT}/../src/OpenCC/src',
      '${PODS_TARGET_SRCROOT}/../src/OpenCC/deps/darts-clone-0.32h/include',
      '${PODS_TARGET_SRCROOT}/../src/OpenCC/deps/marisa-0.3.1/include',
      '${PODS_TARGET_SRCROOT}/../src/OpenCC/deps/marisa-0.3.1/lib',
      '${PODS_TARGET_SRCROOT}/../src/OpenCC/deps/rapidjson-1.1.0',
      '${PODS_TARGET_SRCROOT}/../src/xxHash',
    ].join(' '),
  }

  s.static_framework = true
end
