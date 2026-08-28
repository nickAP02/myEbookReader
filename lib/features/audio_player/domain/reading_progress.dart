import 'package:hive/hive.dart';

part 'reading_progress.g.dart';

@HiveType(typeId: 3)
class ReadingProgress extends HiveObject {
  ReadingProgress({
    required this.bookId,
    required this.currentSegmentIndex,
    required this.lastPlayedAt,
  });

  @HiveField(0)
  final String bookId;

  @HiveField(1)
  int currentSegmentIndex;

  @HiveField(2)
  DateTime lastPlayedAt;
}
