# BookReader

Application mobile Flutter (Android + iOS) qui transforme un livre — PDF, EPUB ou TXT — en lecture audio via synthèse vocale.

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour l'architecture complète, le périmètre fonctionnel par phase et les choix techniques.

## Démarrer

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère les adaptateurs Hive
flutter run
```

## Tests & analyse

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

## CI/CD

- `.github/workflows/ci.yml` : sur chaque push/PR vers `main` — analyse statique, format, tests, build Android (debug) et iOS (no-codesign).
- `.github/workflows/release.yml` : sur un tag `vX.Y.Z` — build un APK et le publie en GitHub Release. La signature de production (Play Store) et la publication iOS (App Store Connect) nécessitent l'ajout de secrets au repo — voir les commentaires en tête du fichier.
