// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordWithHint => 'Password (min. 8 characters)';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get login => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get logout => 'Sign out';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get errInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errEmailTaken => 'This email is already in use.';

  @override
  String get errInvalidData =>
      'Invalid data (password: at least 8 characters).';

  @override
  String get errNetwork => 'Cannot reach the server. Check your connection.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';
}
