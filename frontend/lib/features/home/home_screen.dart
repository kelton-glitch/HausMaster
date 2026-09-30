import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/domain/manager.dart';
import '../auth/presentation/auth_controller.dart';

/// Placeholder landing page; properties/units/etc. will replace this.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.manager});

  final Manager manager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HausMaster'),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(child: Text(l10n.welcome(manager.fullName))),
    );
  }
}
