import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_controller.dart';
import 'core/provider_retry.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() =>
    runApp(const ProviderScope(retry: noAutoRetry, child: HausMasterApp()));

class HausMasterApp extends ConsumerWidget {
  const HausMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return MaterialApp(
      title: 'HausMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // French (Cameroon) is the primary language (NFR-11); English if the device uses it.
      localeResolutionCallback: (device, supported) =>
          device?.languageCode == 'en'
          ? const Locale('en')
          : const Locale('fr'),
      home: switch (auth) {
        // Keep showing the login form while a login attempt is loading or failed.
        AsyncData(:final value?) => HomeScreen(manager: value),
        AsyncLoading(:final hasValue, :final hasError)
            when !hasValue && !hasError =>
          const _Splash(),
        _ => const LoginScreen(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: 'HausMaster',
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}
