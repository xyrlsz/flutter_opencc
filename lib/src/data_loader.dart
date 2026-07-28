import 'dart:io';
import 'package:flutter/services.dart';

/// Utility for extracting bundled OpenCC dictionary data to the filesystem.
///
/// OpenCC's native library requires real filesystem paths for dictionary files.
/// This helper copies the bundled assets (declared in `pubspec.yaml`) to a
/// writable directory at runtime.
///
/// Usage:
/// ```dart
/// final dataDir = await OpenCCData.prepareData();
/// final result = OpenCCSimple.convert('鼠标', OpenCCConfig.s2t, dataDir: dataDir);
/// ```
class OpenCCData {
  OpenCCData._();

  /// Package asset prefix for Flutter asset bundle resolution.
  static const String _assetPrefix =
      'packages/flutter_opencc/assets/openccdata';

  /// List of all bundled OpenCC dictionary and config files.
  ///
  /// These correspond to files under `assets/openccdata/` in the package.
  static const List<String> _bundledFiles = [
    'CJK_Compatibility_Ideographs.ocd2',
    'hk2s.json',
    'hk2sp.json',
    'hk2t.json',
    'HKPhrases.ocd2',
    'HKPhrasesRev.ocd2',
    'HKVariants.ocd2',
    'HKVariantsPhrases.ocd2',
    'HKVariantsRev.ocd2',
    'HKVariantsRevPhrases.ocd2',
    'jp2t.json',
    'JPShinjitaiCharacters.ocd2',
    'JPShinjitaiCharactersRev.ocd2',
    'JPShinjitaiPhrases.ocd2',
    'opencc_config.schema.json',
    's2hk.json',
    's2hkp.json',
    's2t.json',
    's2tw.json',
    's2twp.json',
    'STCharacters.ocd2',
    'STPhrases.ocd2',
    'STPhrases_GeneratedFromRegionalPhrases.ocd2',
    't2hk.json',
    't2jp.json',
    't2s.json',
    't2tw.json',
    'TSCharacters.ocd2',
    'TSCharactersExt.ocd2',
    'TSPhrases.ocd2',
    'tw2s.json',
    'tw2sp.json',
    'tw2t.json',
    'TWPhrases.ocd2',
    'TWPhrasesRev.ocd2',
    'TWVariants.ocd2',
    'TWVariantsPhrases.ocd2',
    'TWVariantsRev.ocd2',
    'TWVariantsRevPhrases.ocd2',
  ];

  /// The [AssetBundle] used to load the bundled data.
  ///
  /// Can be overridden for testing.
  static AssetBundle? _overrideBundle;

  /// Set a custom [AssetBundle] for testing.
  static void set overrideBundle(AssetBundle? bundle) {
    _overrideBundle = bundle;
  }

  /// Get the active asset bundle.
  static AssetBundle get _bundle => _overrideBundle ?? rootBundle;

  /// Extract all bundled OpenCC data files to the specified [targetDir].
  ///
  /// If [targetDir] is `null`, a temporary directory under the system temp
  /// directory will be created (e.g., `{tempDir}/flutter_opencc_data/`).
  ///
  /// Returns the absolute path of the directory containing the extracted data.
  ///
  /// This method is idempotent: already-existing files are skipped unless
  /// [force] is `true`.
  static Future<String> prepareData({
    String? targetDir,
    bool force = false,
  }) async {
    final dir = targetDir ?? _defaultTargetDir();
    final outDir = Directory(dir);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    for (final filename in _bundledFiles) {
      final destPath = '${outDir.path}/$filename';
      final destFile = File(destPath);

      // Skip if file already exists and we're not forcing re-extraction.
      if (!force && await destFile.exists()) {
        continue;
      }

      try {
        final assetKey = '$_assetPrefix/$filename';
        final data = await _bundle.load(assetKey);
        await destFile.writeAsBytes(data.buffer.asUint8List());
      } catch (e) {
        throw OpenCCDataException(
          'Failed to extract bundled asset "$filename": $e',
        );
      }
    }

    return outDir.path;
  }

  /// Verify that all bundled data files exist in [dataDir].
  ///
  /// Returns a list of missing file names. If all files are present,
  /// the list is empty.
  static Future<List<String>> verifyData(String dataDir) async {
    final missing = <String>[];
    for (final filename in _bundledFiles) {
      final file = File('$dataDir/$filename');
      if (!await file.exists()) {
        missing.add(filename);
      }
    }
    return missing;
  }

  /// Get the default target directory for extracted OpenCC data.
  ///
  /// Uses the system temporary directory.
  static String _defaultTargetDir() {
    final tempDir = Directory.systemTemp;
    return '${tempDir.path}/flutter_opencc_data';
  }
}

/// Exception thrown when OpenCC data extraction fails.
class OpenCCDataException implements Exception {
  final String message;
  OpenCCDataException(this.message);

  @override
  String toString() => 'OpenCCDataException: $message';
}
