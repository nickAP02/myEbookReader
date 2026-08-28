import 'dart:io';

import '../../domain/parsed_book.dart';

/// Interface commune à tous les parseurs de format. Ajouter un format
/// (MOBI, DOCX...) revient à ajouter une implémentation ici + une entrée
/// dans [resolveParser], sans toucher au reste de l'app.
abstract class BookParser {
  Future<ParsedBook> parse(File file);
}
