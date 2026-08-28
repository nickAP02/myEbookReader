import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_providers.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider(bookId));
    final controller = ref.read(playerControllerProvider(bookId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: state.isLoading ? null : controller.addBookmark,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.segments.isEmpty
          ? const Center(child: Text('Aucun contenu à lire pour ce livre.'))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.currentText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  if (state.bookmarks.isNotEmpty)
                    _BookmarkRow(bookId: bookId, state: state),
                  _ProgressLabel(state: state),
                  _SpeedSlider(state: state, controller: controller),
                  _PlaybackControls(state: state, controller: controller),
                ],
              ),
            ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${state.currentIndex + 1} / ${state.segments.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _SpeedSlider extends StatelessWidget {
  const _SpeedSlider({required this.state, required this.controller});

  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.speed),
          Expanded(
            child: Slider(
              value: state.speechRate,
              min: 0.2,
              max: 1.0,
              divisions: 8,
              label: '${state.speechRate.toStringAsFixed(1)}x',
              onChanged: controller.setSpeechRate,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.state, required this.controller});

  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.skip_previous),
            onPressed: state.currentIndex > 0 ? controller.previous : null,
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            iconSize: 40,
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: controller.playPause,
          ),
          const SizedBox(width: 12),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.skip_next),
            onPressed: state.currentIndex < state.segments.length - 1
                ? controller.next
                : null,
          ),
        ],
      ),
    );
  }
}

class _BookmarkRow extends ConsumerWidget {
  const _BookmarkRow({required this.bookId, required this.state});

  final String bookId;
  final PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider(bookId).notifier);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.bookmarks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bookmark = state.bookmarks[index];
          return InputChip(
            label: Text('#${bookmark.segmentIndex + 1}'),
            onPressed: () => controller.skipTo(bookmark.segmentIndex),
            onDeleted: () => controller.removeBookmark(bookmark.id),
          );
        },
      ),
    );
  }
}
