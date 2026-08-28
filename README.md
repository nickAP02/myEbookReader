# BookReader

Application mobile Flutter (Android + iOS) qui transforme un livre — PDF, EPUB ou TXT — en lecture audio via synthèse vocale.

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour l'architecture complète, le périmètre fonctionnel par phase et les choix techniques.

## Fonctionnalités actuelles (Phase 1 — MVP local, sans compte)

- **Import** de fichiers PDF, EPUB ou TXT depuis l'appareil
- **Extraction du texte** et découpage automatique en segments (phrases) lisibles par le moteur de synthèse vocale
- **Bibliothèque** locale : liste des livres importés, suppression, persistée hors-ligne (Hive)
- **Lecture audio (TTS)** : lecture/pause, phrase précédente/suivante, réglage de la vitesse de lecture
- **Marque-pages** : ajout/suppression, saut direct à un marque-page
- **Reprise automatique** : la position de lecture est sauvegardée et restaurée à la réouverture d'un livre
- **Thème clair/sombre**

Pas encore présent : comptes utilisateur, synchronisation cloud (Firebase, prévu Phase 2), voix TTS premium, surlignage synchronisé (Phase 3) — voir la roadmap dans [ARCHITECTURE.md](ARCHITECTURE.md#7-roadmap).

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.35.2 ou plus récent (channel stable), Dart 3.9+
- Android : Android Studio + SDK (le projet cible Android via Gradle/Kotlin)
- iOS : Xcode, uniquement sur macOS
- Un appareil physique ou un émulateur/simulateur

Vérifier que l'environnement est prêt :

```bash
flutter doctor
```

## Démarrer à froid (nouvelle machine)

```bash
git clone https://github.com/nickAP02/myEbookReader.git
cd myEbookReader

flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère les adaptateurs Hive (*.g.dart)

flutter devices     # vérifie qu'un appareil ou émulateur est détecté
flutter run
```

## Tests & analyse

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

## CI/CD

- `.github/workflows/ci.yml` : sur chaque push/PR vers `main` — analyse statique, format, tests, build Android (debug) et iOS (no-codesign). L'APK debug généré est téléchargeable depuis l'onglet **Actions** du run (section Artifacts, 14 jours).
- `.github/workflows/release.yml` : sur un tag `vX.Y.Z` (`git tag v0.1.0 && git push --tags`) — build un artefact et le publie en GitHub Release. Tant qu'aucun secret de signature n'est configuré, l'artefact est un APK debug ; dès que les secrets `ANDROID_KEYSTORE_*` existent dans le repo, le job publie un App Bundle (`.aab`) signé, prêt pour le Play Store — voir les commentaires en tête du fichier pour la liste des secrets.
