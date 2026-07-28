/// Supported OpenCC conversion configurations.
///
/// Each variant maps to a JSON configuration file shipped with OpenCC.
/// See https://github.com/BYVoid/OpenCC#configurations for details.
enum OpenCCConfig {
  /// 简体中文 → 标准繁体 (Simplified Chinese → Standard Traditional Chinese)
  s2t('s2t.json'),

  /// 标准繁体 → 简体中文 (Standard Traditional Chinese → Simplified Chinese)
  t2s('t2s.json'),

  /// 简体中文 → 台湾正体 (Simplified Chinese → Taiwanese Traditional)
  s2tw('s2tw.json'),

  /// 台湾正体 → 简体中文 (Taiwanese Traditional → Simplified Chinese)
  tw2s('tw2s.json'),

  /// 简体中文 → 香港繁体 (Simplified Chinese → Hong Kong Traditional)
  s2hk('s2hk.json'),

  /// 香港繁体 → 简体中文 (Hong Kong Traditional → Simplified Chinese)
  hk2s('hk2s.json'),

  /// 简体中文 → 台湾正体（含台湾常用词汇）
  s2twp('s2twp.json'),

  /// 台湾正体 → 简体中文（含中国大陆常用词汇）
  tw2sp('tw2sp.json'),

  /// 标准繁体 → 台湾正体 (Standard Traditional → Taiwanese Traditional)
  t2tw('t2tw.json'),

  /// 台湾正体 → 标准繁体 (Taiwanese Traditional → Standard Traditional)
  tw2t('tw2t.json'),

  /// 标准繁体 → 香港繁体 (Standard Traditional → Hong Kong Traditional)
  t2hk('t2hk.json'),

  /// 香港繁体 → 标准繁体 (Hong Kong Traditional → Standard Traditional)
  hk2t('hk2t.json'),

  /// 简体中文 → 香港繁体（含香港常用词汇）
  s2hkp('s2hkp.json'),

  /// 香港繁体 → 简体中文（含中国大陆常用词汇）
  hk2sp('hk2sp.json'),

  /// 日文旧字体 (Kyūjitai) → 日文新字体 (Shinjitai)
  t2jp('t2jp.json'),

  /// 日文新字体 (Shinjitai) → 日文旧字体 (Kyūjitai)
  jp2t('jp2t.json'),
  ;

  /// The JSON configuration file name for this conversion type.
  final String configFile;
  const OpenCCConfig(this.configFile);

  /// Human-readable description in Chinese.
  String get description {
    switch (this) {
      case OpenCCConfig.s2t:
        return '简体 → 标准繁体';
      case OpenCCConfig.t2s:
        return '标准繁体 → 简体';
      case OpenCCConfig.s2tw:
        return '简体 → 台湾正体';
      case OpenCCConfig.tw2s:
        return '台湾正体 → 简体';
      case OpenCCConfig.s2hk:
        return '简体 → 香港繁体';
      case OpenCCConfig.hk2s:
        return '香港繁体 → 简体';
      case OpenCCConfig.s2twp:
        return '简体 → 台湾正体（含词汇）';
      case OpenCCConfig.tw2sp:
        return '台湾正体 → 简体（含词汇）';
      case OpenCCConfig.t2tw:
        return '标准繁体 → 台湾正体';
      case OpenCCConfig.tw2t:
        return '台湾正体 → 标准繁体';
      case OpenCCConfig.t2hk:
        return '标准繁体 → 香港繁体';
      case OpenCCConfig.hk2t:
        return '香港繁体 → 标准繁体';
      case OpenCCConfig.s2hkp:
        return '简体 → 香港繁体（含词汇）';
      case OpenCCConfig.hk2sp:
        return '香港繁体 → 简体（含词汇）';
      case OpenCCConfig.t2jp:
        return '日文旧字体 → 日文新字体';
      case OpenCCConfig.jp2t:
        return '日文新字体 → 日文旧字体';
    }
  }
}
