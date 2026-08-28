import 'package:flutter_tts/flutter_tts.dart';

/// Fine encapsulation de flutter_tts : un service unique réutilisé par le lecteur.
class TtsService {
  TtsService() {
    _tts.setCompletionHandler(() => _onComplete?.call());
    _tts.setErrorHandler((msg) => _onError?.call(msg.toString()));
  }

  final FlutterTts _tts = FlutterTts();
  void Function()? _onComplete;
  void Function(String message)? _onError;

  void onComplete(void Function() callback) => _onComplete = callback;
  void onError(void Function(String message) callback) => _onError = callback;

  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> setVoice(Map<String, String> voice) => _tts.setVoice(voice);

  Future<List<Map<String, String>>> getVoices() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return [];
    return voices
        .whereType<Map>()
        .map(
          (v) =>
              v.map((key, value) => MapEntry(key.toString(), value.toString())),
        )
        .toList();
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> pause() => _tts.pause();

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();
}
