import 'package:hive/hive.dart';

import '../domain/reading_progress.dart';

class ProgressRepository {
  Box<ReadingProgress> get _box =>
      Hive.box<ReadingProgress>('reading_progress');

  ReadingProgress? get(String bookId) => _box.get(bookId);

  Future<void> save(String bookId, int segmentIndex) async {
    final existing = _box.get(bookId);
    if (existing != null) {
      existing
        ..currentSegmentIndex = segmentIndex
        ..lastPlayedAt = DateTime.now();
      await existing.save();
    } else {
      await _box.put(
        bookId,
        ReadingProgress(
          bookId: bookId,
          currentSegmentIndex: segmentIndex,
          lastPlayedAt: DateTime.now(),
        ),
      );
    }
  }
}
