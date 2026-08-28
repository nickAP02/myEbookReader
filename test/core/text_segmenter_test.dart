import 'package:bookreader/core/utils/text_segmenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextSegmenter', () {
    test('splits text into sentences on . ! ?', () {
      const text = 'Bonjour le monde. Comment vas-tu ? Très bien !';
      final segments = TextSegmenter.segment(text);

      expect(segments, [
        'Bonjour le monde.',
        'Comment vas-tu ?',
        'Très bien !',
      ]);
    });

    test('collapses extra whitespace and newlines', () {
      const text = 'Une   phrase\n\nsur   plusieurs lignes.';
      final segments = TextSegmenter.segment(text);

      expect(segments, ['Une phrase sur plusieurs lignes.']);
    });

    test('returns an empty list for empty input', () {
      expect(TextSegmenter.segment('   '), isEmpty);
    });

    test('falls back to the whole text when there is no punctuation', () {
      const text = 'un texte sans ponctuation finale';
      expect(TextSegmenter.segment(text), [text]);
    });
  });
}
