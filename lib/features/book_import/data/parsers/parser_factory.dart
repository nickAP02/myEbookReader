import 'package:path/path.dart' as p;

import '../../../../core/errors/failure.dart';
import 'book_parser.dart';
import 'epub_parser.dart';
import 'pdf_parser.dart';
import 'txt_parser.dart';

BookParser resolveParser(String filePath) {
  final extension = p.extension(filePath).toLowerCase();
  switch (extension) {
    case '.pdf':
      return PdfParser();
    case '.epub':
      return EpubParser();
    case '.txt':
      return TxtParser();
    default:
      throw UnsupportedFormatFailure(extension);
  }
}
