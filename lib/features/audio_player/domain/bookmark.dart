import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 4)
class Bookmark extends HiveObject {
  Bookmark({
    required this.id,
    required this.bookId,
    required this.segmentIndex,
    this.label,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final int segmentIndex;

  @HiveField(3)
  String? label;

  @HiveField(4)
  final DateTime createdAt;
}
