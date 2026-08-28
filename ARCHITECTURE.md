# BookReader — Architecture technique

Application mobile Flutter qui permet d'importer un livre (PDF, EPUB, TXT...) et de l'écouter en audio via synthèse vocale (TTS), avec suivi de progression, marque-pages et synchronisation multi-appareils.

> Statut : proposition d'architecture — en attente de validation avant tout développement.

---

## 1. Périmètre fonctionnel

### Phase 1 — MVP local (sans compte)
- Import de fichiers depuis l'appareil : **PDF, EPUB, TXT**
- Bibliothèque locale (liste des livres importés, couverture, titre, auteur si détectable)
- Extraction du texte et découpage en segments lisibles (chapitres / paragraphes / phrases)
- Lecture audio du texte via TTS **on-device** (gratuit, fonctionne hors-ligne)
- Contrôles de lecture : play / pause / stop, avancer/reculer d'une phrase ou d'un chapitre, vitesse de lecture, choix de la voix
- Lecture en arrière-plan + contrôles sur écran de verrouillage / notification
- Sauvegarde locale de la progression (reprise automatique) et des marque-pages
- Réglages : voix, vitesse, thème clair/sombre

### Phase 2 — Backend & synchronisation
- Authentification (email/mot de passe, Google Sign-In)
- Synchronisation multi-appareils des **métadonnées** de bibliothèque, de la progression de lecture et des marque-pages
- Mode hors-ligne conservé (le local reste la source de vérité, le cloud synchronise)

### Phase 3 — Extras (post-validation du socle)
- Voix TTS premium via un service cloud (meilleure qualité, autres langues)
- Formats additionnels (MOBI, DOCX...)
- Surlignage du mot/de la phrase en cours de lecture, synchronisé à l'audio
- Export / partage de la progression

**Hors périmètre (à confirmer) :** web et desktop. L'app cible **Android + iOS** ; les choix de packages (lecture audio en arrière-plan, sélection de fichiers) sont faits pour mobile.

---

## 2. Stack technique

| Domaine | Choix | Raison |
|---|---|---|
| Langage / SDK | Flutter (stable) / Dart | Un seul code base Android + iOS |
| Gestion d'état | **Riverpod** (`flutter_riverpod`) | Testable, peu de boilerplate, s'intègre bien avec un découpage feature-first |
| Navigation | `go_router` | Routes déclaratives, gestion propre des deep links |
| Import fichiers | `file_picker` | Sélection de fichiers depuis le stockage de l'appareil |
| Extraction PDF | `syncfusion_flutter_pdf` | Extraction de texte fiable (licence Community gratuite pour indépendant/petite structure — à vérifier selon usage) |
| Extraction EPUB | `epubx` | Parsing de la structure EPUB (chapitres, texte) |
| TTS on-device | `flutter_tts` | Gratuit, fonctionne hors-ligne, Android + iOS |
| Lecture arrière-plan | `audio_service` | Notification / écran de verrouillage, cycle de vie audio correct en arrière-plan |
| Stockage local | `hive` / `hive_flutter` | Simple, rapide, suffisant pour métadonnées de livres, progression, marque-pages |
| Chemins fichiers | `path_provider` | Copie des fichiers importés dans le stockage de l'app |
| Backend (Phase 2) | Firebase (`firebase_auth`, `cloud_firestore`) | Mise en place rapide, offline persistence intégrée, pas de serveur à maintenir |
| Modèles immuables | `freezed` + `json_serializable` (optionnel) | Réduit le boilerplate des modèles, à introduire si le nombre de modèles le justifie |

**Décision volontairement évitée pour rester proportionné au projet :** pas de clean architecture à 4-5 couches, pas d'injection de dépendances complexe (Riverpod fait déjà office de DI), pas de backend custom à héberger.

---

## 3. Modèle de données

```
Book
├── id: String
├── title: String
├── author: String?
├── format: BookFormat (pdf | epub | txt)
├── localFilePath: String
├── coverImagePath: String?
├── importedAt: DateTime
└── totalSegments: int          // nb de phrases/paragraphes extraits

ReadingProgress
├── bookId: String
├── currentSegmentIndex: int
├── lastPlayedAt: DateTime

Bookmark
├── id: String
├── bookId: String
├── segmentIndex: int
├── label: String?
├── createdAt: DateTime

UserSettings
├── defaultVoiceId: String?
├── speechRate: double
├── themeMode: light | dark | system
```

En Phase 2, `ReadingProgress` et `Bookmark` sont répliqués dans Firestore sous `users/{uid}/books/{bookId}/...`. **Le fichier du livre lui-même (PDF/EPUB) reste local, il n'est pas uploadé** — seules les métadonnées et la progression sont synchronisées (évite les coûts de stockage cloud et les questions de droits d'auteur sur le contenu). Point à valider.

---

## 4. Structure des dossiers

Découpage **feature-first**, chaque feature suit un mini-découpage `data / domain / presentation` (sans sur-architecturer — c'est le seul niveau de séparation).

```
lib/
├── main.dart
├── app.dart                        # MaterialApp.router, thème global
│
├── core/
│   ├── router/                     # config go_router
│   ├── theme/
│   ├── errors/                     # Failure / exceptions custom
│   ├── constants/
│   └── services/
│       ├── tts_service.dart        # wrapper flutter_tts
│       └── audio_playback_service.dart  # intégration audio_service
│
├── features/
│   ├── library/
│   │   ├── data/                   # hive_datasource, firestore_datasource (Phase 2), repository_impl
│   │   ├── domain/                 # Book, repository interface
│   │   └── presentation/           # écran liste bibliothèque, providers Riverpod
│   │
│   ├── book_import/
│   │   ├── data/
│   │   │   └── parsers/
│   │   │       ├── book_parser.dart        # interface commune
│   │   │       ├── pdf_parser.dart
│   │   │       ├── epub_parser.dart
│   │   │       └── txt_parser.dart
│   │   ├── domain/
│   │   └── presentation/           # écran d'import, sélection de fichier
│   │
│   ├── audio_player/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/           # écran lecteur, contrôles, sélection voix/vitesse
│   │
│   ├── bookmarks_progress/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── auth/                       # Phase 2
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/
│       └── presentation/
│
└── shared/
    └── widgets/                    # boutons, loaders, empty states réutilisables
```

L'interface commune `BookParser` (méthode `Future<List<String>> extractSegments(File file)`) permet d'ajouter un nouveau format en Phase 3 (MOBI, DOCX...) sans toucher au reste de l'app — juste une nouvelle implémentation + entrée dans la factory de sélection par extension.

---

## 5. Flux principal (import → écoute)

1. **Import** : l'utilisateur choisit un fichier (`file_picker`) → copie dans le stockage de l'app (`path_provider`) → détection du format par extension.
2. **Parsing** : la factory sélectionne le `BookParser` adapté → extraction du texte, découpage en segments (phrase ou paragraphe) → résultat mis en cache dans Hive (associé au `Book`), pour ne pas re-parser à chaque ouverture.
3. **Lecture** : l'écran lecteur charge les segments → les envoie séquentiellement à `flutter_tts` → `audio_service` gère la session audio en arrière-plan et les contrôles notification/écran verrouillé.
4. **Progression** : l'index du segment courant est sauvegardé régulièrement (Hive), synchronisé vers Firestore si connecté et authentifié (Phase 2).

---

## 6. Gestion des erreurs & tests

- `core/errors` : classes `Failure` scellées (`ParsingFailure`, `StorageFailure`, `NetworkFailure`...), les repositories retournent un résultat typé plutôt que de laisser fuiter des exceptions brutes dans l'UI.
- Les écrans consomment l'état via `AsyncValue` (Riverpod) → gestion uniforme des états loading/error/data.
- Tests unitaires : parsers (un fichier d'exemple par format), repositories.
- Widget tests : écran bibliothèque (liste vide / remplie), écran lecteur (contrôles de base).

---

## 7. Roadmap

| Phase | Contenu | Backend requis |
|---|---|---|
| 1 — MVP | Import, bibliothèque locale, parsing PDF/EPUB/TXT, lecture TTS avec contrôles + arrière-plan, progression/marque-pages locaux, réglages | Non |
| 2 — Sync | Auth Firebase, synchronisation métadonnées/progression/marque-pages multi-appareils | Oui (Firebase) |
| 3 — Extras | Voix cloud premium, formats additionnels, surlignage synchronisé | Oui (Cloud Function proxy pour la clé API TTS cloud) |

---

## 8. Points à valider avant de démarrer le développement

1. **Backend** : Firebase (proposé, rapide à mettre en place) ou API custom ?
2. **Formats du MVP** : PDF + EPUB + TXT couvre la grande majorité des cas — on garde ce périmètre pour la Phase 1 et on étend ensuite ?
3. **Fichiers en local uniquement** (pas d'upload du PDF/EPUB vers le cloud, seulement les métadonnées) — OK ?
4. **TTS on-device pour le MVP** (gratuit, hors-ligne) plutôt qu'un service cloud payant dès le départ — OK ?
5. **Plateformes cibles** : Android + iOS uniquement pour l'instant (pas de web/desktop) ?
6. **Authentification dès le MVP ou seulement en Phase 2** (app 100 % locale d'abord, compte ajouté ensuite) ?

Dès validation (ou ajustements), je scaffold le projet Flutter et démarre l'implémentation en suivant cette structure.
