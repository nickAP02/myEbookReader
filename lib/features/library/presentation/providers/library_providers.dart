import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_book_repository.dart';
import '../../domain/book.dart';
import '../../domain/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => HiveBookRepository(),
);

final libraryProvider = AsyncNotifierProvider<LibraryController, List<Book>>(
  LibraryController.new,
);

class LibraryController extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() {
    return ref.read(bookRepositoryProvider).getAllBooks();
  }

  Future<void> importFile(File file) async {
    final repository = ref.read(bookRepositoryProvider);
    await repository.importFile(file);
    state = await AsyncValue.guard(() => repository.getAllBooks());
  }

  Future<void> deleteBook(String bookId) async {
    final repository = ref.read(bookRepositoryProvider);
    await repository.deleteBook(bookId);
    state = await AsyncValue.guard(() => repository.getAllBooks());
  }
}
