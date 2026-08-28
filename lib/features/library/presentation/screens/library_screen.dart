import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/book.dart';
import '../providers/library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _importing = false;

  Future<void> _importBook() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'epub', 'txt'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() => _importing = true);
    try {
      await ref.read(libraryProvider.notifier).importFile(File(path));
    } on Failure catch (f) {
      _showError(f.message);
    } catch (_) {
      _showError('Impossible d\'importer ce fichier.');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma bibliothèque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: libraryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          message: 'Erreur de chargement de la bibliothèque.\n$error',
        ),
        data: (books) {
          if (books.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              message:
                  'Aucun livre pour l\'instant.\nImporte un PDF, un EPUB ou un TXT pour commencer.',
            );
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) => _BookTile(book: books[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importing ? null : _importBook,
        icon: _importing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_importing ? 'Import en cours...' : 'Importer un livre'),
      ),
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({required this.book});

  final Book book;

  IconData get _formatIcon {
    switch (book.format) {
      case BookFormat.pdf:
        return Icons.picture_as_pdf_outlined;
      case BookFormat.epub:
        return Icons.auto_stories_outlined;
      case BookFormat.txt:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_formatIcon),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(book.author ?? '${book.totalSegments} segments'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => ref.read(libraryProvider.notifier).deleteBook(book.id),
      ),
      onTap: () => context.push('/player/${book.id}'),
    );
  }
}
