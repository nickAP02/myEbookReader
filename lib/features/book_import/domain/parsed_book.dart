/// Résultat brut de l'extraction d'un fichier, avant persistance en [Book]/[BookContent].
class ParsedBook {
  ParsedBook({required this.title, this.author, required this.segments});

  final String title;
  final String? author;
  final List<String> segments;
}
