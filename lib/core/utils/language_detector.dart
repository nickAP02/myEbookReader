/// Heuristique légère (mots-outils + accents) pour choisir la bonne voix
/// TTS entre français et anglais — pas une vraie détection NLP, mais
/// suffisante pour éviter de lire un livre anglais avec une voix française
/// (ou l'inverse), ce qui dégrade fortement le rendu.
class LanguageDetector {
  static const _frenchStopwords = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'de',
    'du',
    'et',
    'est',
    'dans',
    'pour',
    'que',
    'qui',
    'avec',
    'sur',
    'pas',
    'ne',
    'il',
    'elle',
    'vous',
    'nous',
    'ce',
    'cette',
    'où',
    'mais',
    'comme',
    'plus',
    'ses',
    'son',
    'sa',
  };

  static const _englishStopwords = {
    'the',
    'and',
    'is',
    'in',
    'of',
    'to',
    'a',
    'that',
    'it',
    'for',
    'with',
    'on',
    'was',
    'are',
    'this',
    'you',
    'as',
    'be',
    'his',
    'her',
    'not',
    'but',
  };

  static const _frenchAccents = 'àâäéèêëïîôöùûüçœ';

  static String detectLanguageTag(String sample) {
    final words = sample
        .toLowerCase()
        .split(RegExp(r"[^a-zà-ÿ']+"))
        .where((w) => w.isNotEmpty);

    var frenchScore = 0;
    var englishScore = 0;
    for (final word in words) {
      if (_frenchStopwords.contains(word)) frenchScore++;
      if (_englishStopwords.contains(word)) englishScore++;
    }
    frenchScore += _countFrenchAccents(sample);

    return englishScore > frenchScore ? 'en-US' : 'fr-FR';
  }

  static int _countFrenchAccents(String text) {
    var count = 0;
    for (final rune in text.toLowerCase().runes) {
      if (_frenchAccents.contains(String.fromCharCode(rune))) count++;
    }
    return count;
  }
}
