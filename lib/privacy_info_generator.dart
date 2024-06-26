abstract final class PrivacyInfoGenerator {
  static String generatePrivacyInfoXml(
    Map<String, Set<String>> selectedReasons,
  ) {
    final entries = <Map<String, dynamic>>[];

    selectedReasons.forEach((categoryKey, reasonKeys) {
      final reasonKeyList = reasonKeys.toList();
      final entry = <String, dynamic>{
        'NSPrivacyAccessedAPIType': categoryKey,
        'NSPrivacyAccessedAPITypeReasons': reasonKeyList,
      };
      entries.add(entry);
    });

    final plist = <String, dynamic>{'NSPrivacyAccessedAPITypes': entries};

    final xmlContent = _generateXml(plist);
    return xmlContent;
  }

  static String _generateXml(Map<String, dynamic> plist) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
      )
      ..writeln('<plist version="1.0">')
      ..writeln('<dict>');

    plist.forEach((key, value) {
      buffer.writeln('<key>$key</key>');
      _writeValue(buffer, value, 1);
    });

    buffer
      ..writeln('</dict>')
      ..writeln('</plist>');

    return buffer.toString();
  }

  static void _writeValue(StringBuffer buffer, dynamic value, int depth) {
    final indent = '  ' * depth;
    if (value is Map<String, dynamic>) {
      buffer.writeln('$indent<dict>');
      value.forEach((key, value) {
        buffer.writeln('$indent  <key>$key</key>');
        _writeValue(buffer, value, depth + 1);
      });
      buffer.writeln('$indent</dict>');
    } else if (value is List) {
      buffer.writeln('$indent<array>');
      for (final element in value) {
        _writeValue(buffer, element, depth + 1);
      }
      buffer.writeln('$indent</array>');
    } else if (value is String) {
      buffer.writeln('$indent<string>$value</string>');
    }
  }
}
