import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
enum BookFormat {
  @HiveField(0)
  pdf,
  @HiveField(1)
  epub,
  @HiveField(2)
  txt,
}

@HiveType(typeId: 1)
class Book extends HiveObject {
  Book({
    required this.id,
    required this.title,
    this.author,
    required this.format,
    required this.localFilePath,
    this.coverImagePath,
    required this.importedAt,
    required this.totalSegments,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? author;

  @HiveField(3)
  final BookFormat format;

  @HiveField(4)
  final String localFilePath;

  @HiveField(5)
  String? coverImagePath;

  @HiveField(6)
  final DateTime importedAt;

  @HiveField(7)
  final int totalSegments;
}
