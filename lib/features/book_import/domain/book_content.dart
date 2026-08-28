import 'package:hive/hive.dart';

part 'book_content.g.dart';

/// Texte extrait d'un [Book], découpé en segments (phrases/paragraphes)
/// lisibles séquentiellement par le TTS. Stocké séparément du [Book]
/// pour ne pas alourdir la liste de la bibliothèque.
@HiveType(typeId: 2)
class BookContent extends HiveObject {
  BookContent({required this.bookId, required this.segments});

  @HiveField(0)
  final String bookId;

  @HiveField(1)
  final List<String> segments;
}
