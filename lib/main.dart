import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/audio_player/domain/bookmark.dart';
import 'features/audio_player/domain/reading_progress.dart';
import 'features/book_import/domain/book_content.dart';
import 'features/library/domain/book.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  runApp(const ProviderScope(child: BookReaderApp()));
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(BookFormatAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(BookContentAdapter());
  Hive.registerAdapter(ReadingProgressAdapter());
  Hive.registerAdapter(BookmarkAdapter());

  await Hive.openBox<Book>('books');
  await Hive.openBox<BookContent>('book_content');
  await Hive.openBox<ReadingProgress>('reading_progress');
  await Hive.openBox<Bookmark>('bookmarks');
}
