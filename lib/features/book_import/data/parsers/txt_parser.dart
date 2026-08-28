import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../core/utils/text_segmenter.dart';
import '../../domain/parsed_book.dart';
import 'book_parser.dart';

class TxtParser implements BookParser {
  @override
  Future<ParsedBook> parse(File file) async {
    final content = await file.readAsString();
    final title = p.basenameWithoutExtension(file.path);
    return ParsedBook(title: title, segments: TextSegmenter.segment(content));
  }
}
