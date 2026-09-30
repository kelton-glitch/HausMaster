import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';

/// Turns a controller error into a localized, user-facing message.
String authErrorText(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;
  if (error is! AuthException) return l10n.errGeneric;
  return switch (error.error) {
    AuthError.invalidCredentials => l10n.errInvalidCredentials,
    AuthError.emailTaken => l10n.errEmailTaken,
    AuthError.invalidData => l10n.errInvalidData,
    AuthError.network => l10n.errNetwork,
    AuthError.generic => l10n.errGeneric,
  };
}
