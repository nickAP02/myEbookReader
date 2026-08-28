/// Découpe un texte brut en segments (phrases) pour une lecture TTS séquentielle.
class TextSegmenter {
  static final _sentenceRegex = RegExp(r'[^.!?]+[.!?]+(\s+|$)|[^.!?]+$');

  static List<String> segment(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return [];

    final segments = _sentenceRegex
        .allMatches(normalized)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return segments.isEmpty ? [normalized] : segments;
  }
}
