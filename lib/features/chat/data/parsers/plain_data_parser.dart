import 'dart:convert';

class PlainChannelCollector {
  const PlainChannelCollector._();

  static String collectByTag(String rawResponse, String tag) {
    final buffer = StringBuffer();
    for (final rawLine in rawResponse.split(RegExp(r'\r?\n'))) {
      final text = parseLineByTag(rawLine, tag);
      if (text != null && text.isNotEmpty) buffer.write(text);
    }
    return buffer.toString();
  }

  static String? parseLineByTag(String line, String tag) {
    final s = line.trim();
    if (s.isEmpty) return null;

    final sep = s.indexOf(':');
    if (sep <= 0) return null;

    final prefix = s.substring(0, sep);
    if (prefix != tag) return null;

    final payload = s.substring(sep + 1).trim();
    return payloadToText(payload);
  }

  static String? payloadToText(String payload) {
    final p = payload.trim();
    if (p.isEmpty) return null;

    if (p.length >= 2 && p.startsWith('"') && p.endsWith('"')) {
      try {
        return jsonDecode(p) as String;
      } on Exception catch (_) {
        return p.substring(1, p.length - 1);
      }
    }

    return p;
  }
}
