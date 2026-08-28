import 'dart:io';

import 'package:epubx/epubx.dart' as epubx;
import 'package:path/path.dart' as p;

import '../../../../core/utils/text_segmenter.dart';
import '../../domain/parsed_book.dart';
import 'book_parser.dart';

class EpubParser implements BookParser {
  @override
  Future<ParsedBook> parse(File file) async {
    final bytes = await file.readAsBytes();
    final book = await epubx.EpubReader.readBook(bytes);

    final buffer = StringBuffer();
    for (final chapter in book.Chapters ?? const <epubx.EpubChapter>[]) {
      _appendChapter(buffer, chapter);
    }

    final title = book.Title ?? p.basenameWithoutExtension(file.path);
    return ParsedBook(
      title: title,
      author: book.Author,
      segments: TextSegmenter.segment(buffer.toString()),
    );
  }

  void _appendChapter(StringBuffer buffer, epubx.EpubChapter chapter) {
    final html = chapter.HtmlContent ?? '';
    final plainText = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    buffer.writeln(plainText);
    for (final sub in chapter.SubChapters ?? const <epubx.EpubChapter>[]) {
      _appendChapter(buffer, sub);
    }
  }
}
