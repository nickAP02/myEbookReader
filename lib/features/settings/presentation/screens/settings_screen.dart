import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Les réglages avancés (voix, compte, synchronisation) arrivent '
            'avec la Phase 2 (Firebase).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
