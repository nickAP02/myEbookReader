import 'dart:io';

import 'book.dart';

abstract class BookRepository {
  Future<List<Book>> getAllBooks();

  Future<Book> importFile(File pickedFile);

  Future<List<String>> getSegments(String bookId);

  Future<void> deleteBook(String bookId);
}
