import 'package:go_router/go_router.dart';

import '../../features/audio_player/presentation/screens/player_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LibraryScreen()),
    GoRoute(
      path: '/player/:bookId',
      builder: (context, state) =>
          PlayerScreen(bookId: state.pathParameters['bookId']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
