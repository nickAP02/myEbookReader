import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../audio_player/domain/bookmark.dart';
import '../../audio_player/domain/reading_progress.dart';
import '../../book_import/data/parsers/parser_factory.dart';
import '../../book_import/domain/book_content.dart';
import '../domain/book.dart';
import '../domain/book_repository.dart';

class HiveBookRepository implements BookRepository {
  final _uuid = const Uuid();

  Box<Book> get _books => Hive.box<Book>('books');
  Box<BookContent> get _content => Hive.box<BookContent>('book_content');
  Box<ReadingProgress> get _progress =>
      Hive.box<ReadingProgress>('reading_progress');
  Box<Bookmark> get _bookmarks => Hive.box<Bookmark>('bookmarks');

  @override
  Future<List<Book>> getAllBooks() async {
    final books = _books.values.toList();
    books.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return books;
  }

  @override
  Future<Book> importFile(File pickedFile) async {
    final id = _uuid.v4();
    final storedFile = await _copyToAppStorage(pickedFile, id);

    final parser = resolveParser(storedFile.path);
    final parsed = await parser.parse(storedFile);

    final book = Book(
      id: id,
      title: parsed.title,
      author: parsed.author,
      format: _formatFor(storedFile.path),
      localFilePath: storedFile.path,
      importedAt: DateTime.now(),
      totalSegments: parsed.segments.length,
    );

    await _books.put(id, book);
    await _content.put(id, BookContent(bookId: id, segments: parsed.segments));

    return book;
  }

  @override
  Future<List<String>> getSegments(String bookId) async {
    return _content.get(bookId)?.segments ?? const [];
  }

  @override
  Future<void> deleteBook(String bookId) async {
    final book = _books.get(bookId);
    await _books.delete(bookId);
    await _content.delete(bookId);
    await _progress.delete(bookId);

    final staleBookmarks = _bookmarks.values
        .where((b) => b.bookId == bookId)
        .toList();
    for (final bookmark in staleBookmarks) {
      await bookmark.delete();
    }

    if (book != null) {
      final file = File(book.localFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<File> _copyToAppStorage(File pickedFile, String id) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(docsDir.path, 'books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    final extension = p.extension(pickedFile.path);
    final destination = p.join(booksDir.path, '$id$extension');
    return pickedFile.copy(destination);
  }

  BookFormat _formatFor(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.pdf':
        return BookFormat.pdf;
      case '.epub':
        return BookFormat.epub;
      default:
        return BookFormat.txt;
    }
  }
}
