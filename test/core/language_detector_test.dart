import 'package:bookreader/core/utils/language_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguageDetector', () {
    test('detects French text', () {
      const text =
          'Le chat est sur la table et il regarde par la fenêtre avec curiosité.';
      expect(LanguageDetector.detectLanguageTag(text), 'fr-FR');
    });

    test('detects English text', () {
      const text =
          'The cat is on the table and it is looking out of the window with curiosity.';
      expect(LanguageDetector.detectLanguageTag(text), 'en-US');
    });

    test('defaults to French on ambiguous/empty input', () {
      expect(LanguageDetector.detectLanguageTag(''), 'fr-FR');
    });
  });
}
