import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/tts_service.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../data/bookmark_repository.dart';
import '../../data/progress_repository.dart';
import '../../domain/bookmark.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) => BookmarkRepository(),
);

class PlayerState {
  const PlayerState({
    required this.segments,
    required this.currentIndex,
    required this.isPlaying,
    required this.isLoading,
    required this.speechRate,
    required this.bookmarks,
    this.error,
  });

  static const initial = PlayerState(
    segments: [],
    currentIndex: 0,
    isPlaying: false,
    isLoading: true,
    speechRate: 0.5,
    bookmarks: [],
  );

  final List<String> segments;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final double speechRate;
  final List<Bookmark> bookmarks;
  final String? error;

  String get currentText =>
      currentIndex < segments.length ? segments[currentIndex] : '';

  PlayerState copyWith({
    List<String>? segments,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    double? speechRate,
    List<Bookmark>? bookmarks,
    String? error,
  }) {
    return PlayerState(
      segments: segments ?? this.segments,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      speechRate: speechRate ?? this.speechRate,
      bookmarks: bookmarks ?? this.bookmarks,
      error: error,
    );
  }
}

final playerControllerProvider =
    NotifierProvider.family<PlayerController, PlayerState, String>(
      PlayerController.new,
    );

class PlayerController extends Notifier<PlayerState> {
  PlayerController(this.bookId);

  final String bookId;
  late final TtsService _tts;

  @override
  PlayerState build() {
    _tts = TtsService();
    _tts.onComplete(_onSegmentComplete);
    _tts.onError((_) => state = state.copyWith(isPlaying: false));
    ref.onDispose(() => _tts.dispose());

    Future.microtask(_load);
    return PlayerState.initial;
  }

  Future<void> _load() async {
    final repository = ref.read(bookRepositoryProvider);
    final book = await repository.getBook(bookId);
    await _tts.setLanguage(book?.languageTag ?? 'fr-FR');

    final segments = await repository.getSegments(bookId);
    final progress = ref.read(progressRepositoryProvider).get(bookId);
    final bookmarks = ref.read(bookmarkRepositoryProvider).forBook(bookId);
    state = state.copyWith(
      segments: segments,
      currentIndex: progress?.currentSegmentIndex ?? 0,
      bookmarks: bookmarks,
      isLoading: false,
    );
  }

  Future<void> playPause() async {
    if (state.isPlaying) {
      await _tts.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      state = state.copyWith(isPlaying: true);
      await _speakCurrent();
    }
  }

  Future<void> _speakCurrent() async {
    if (state.currentIndex >= state.segments.length) {
      state = state.copyWith(isPlaying: false);
      return;
    }
    await _tts.setSpeechRate(state.speechRate);
    await _tts.speak(state.currentText);
  }

  void _onSegmentComplete() {
    if (!state.isPlaying) return;
    final next = state.currentIndex + 1;
    if (next >= state.segments.length) {
      state = state.copyWith(isPlaying: false);
      return;
    }
    state = state.copyWith(currentIndex: next);
    ref.read(progressRepositoryProvider).save(bookId, next);
    _speakCurrent();
  }

  Future<void> stop() async {
    await _tts.stop();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> skipTo(int index) async {
    final clamped = index.clamp(
      0,
      state.segments.isEmpty ? 0 : state.segments.length - 1,
    );
    await _tts.stop();
    state = state.copyWith(currentIndex: clamped);
    await ref.read(progressRepositoryProvider).save(bookId, clamped);
    if (state.isPlaying) await _speakCurrent();
  }

  Future<void> next() => skipTo(state.currentIndex + 1);

  Future<void> previous() => skipTo(state.currentIndex - 1);

  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _tts.setSpeechRate(rate);
  }

  Future<void> addBookmark() async {
    await ref.read(bookmarkRepositoryProvider).add(bookId, state.currentIndex);
    state = state.copyWith(
      bookmarks: ref.read(bookmarkRepositoryProvider).forBook(bookId),
    );
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await ref.read(bookmarkRepositoryProvider).remove(bookmarkId);
    state = state.copyWith(
      bookmarks: ref.read(bookmarkRepositoryProvider).forBook(bookId),
    );
  }
}
