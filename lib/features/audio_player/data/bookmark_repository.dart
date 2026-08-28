import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/bookmark.dart';

class BookmarkRepository {
  final _uuid = const Uuid();

  Box<Bookmark> get _box => Hive.box<Bookmark>('bookmarks');

  List<Bookmark> forBook(String bookId) {
    final bookmarks = _box.values.where((b) => b.bookId == bookId).toList();
    bookmarks.sort((a, b) => a.segmentIndex.compareTo(b.segmentIndex));
    return bookmarks;
  }

  Future<void> add(String bookId, int segmentIndex) async {
    final id = _uuid.v4();
    await _box.put(
      id,
      Bookmark(
        id: id,
        bookId: bookId,
        segmentIndex: segmentIndex,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> remove(String bookmarkId) => _box.delete(bookmarkId);
}
