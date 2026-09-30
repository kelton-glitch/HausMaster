import '../../../l10n/app_localizations.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateRequired(AppLocalizations l10n, String? v) =>
    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

String? validateEmail(AppLocalizations l10n, String? v) {
  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
  return _emailRe.hasMatch(v.trim()) ? null : l10n.invalidEmail;
}

String? validateNewPassword(AppLocalizations l10n, String? v) =>
    (v == null || v.length < 8) ? l10n.passwordTooShort : null;
