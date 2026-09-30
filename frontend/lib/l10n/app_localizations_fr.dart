// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordWithHint => 'Mot de passe (8 caractères min.)';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneOptional => 'Téléphone (optionnel)';

  @override
  String get login => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String welcome(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get fieldRequired => 'Requis';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get passwordTooShort => '8 caractères minimum';

  @override
  String get errInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get errEmailTaken => 'Cet email est déjà utilisé.';

  @override
  String get errInvalidData =>
      'Données invalides (mot de passe : 8 caractères minimum).';

  @override
  String get errNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get errGeneric => 'Une erreur est survenue. Réessayez.';
}
