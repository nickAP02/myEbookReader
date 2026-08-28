import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/utils/text_segmenter.dart';
import '../../domain/parsed_book.dart';
import 'book_parser.dart';

class PdfParser implements BookParser {
  @override
  Future<ParsedBook> parse(File file) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    try {
      final text = PdfTextExtractor(document).extractText();
      final title = p.basenameWithoutExtension(file.path);
      return ParsedBook(title: title, segments: TextSegmenter.segment(text));
    } finally {
      document.dispose();
    }
  }
}
