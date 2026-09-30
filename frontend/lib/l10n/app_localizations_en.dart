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
  String get passwordWithHint => 'Password';

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
  String get haveAccount => 'I already have an account';

  @override
  String get logout => 'Sign out';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your rentals.';

  @override
  String get registerSubtitle => 'Track rent, tenants and bills in one place.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordRuleLength => 'At least 8 characters';

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

  @override
  String get tabDashboard => 'Home';

  @override
  String get tabProperties => 'Properties';

  @override
  String get tabRent => 'Rent';

  @override
  String get tabProfile => 'Profile';

  @override
  String get gettingStarted => 'Getting started';

  @override
  String get stepProperty => 'Add a property';

  @override
  String get stepTenant => 'Register a tenant';

  @override
  String get stepLease => 'Create a lease';

  @override
  String get comingSoon => 'Soon';

  @override
  String get emptyPropertiesTitle => 'No properties yet';

  @override
  String get emptyPropertiesBody =>
      'Your buildings and units will appear here.';

  @override
  String get emptyRentTitle => 'No rent to track';

  @override
  String get emptyRentBody =>
      'The rent ledger fills up once a lease is created.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Auto';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody =>
      'You’ll need to sign in again to access your data.';

  @override
  String get cancel => 'Cancel';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsNote =>
      'Sending notifications will be enabled soon. Your choices are already saved.';

  @override
  String get notifRentDue => 'Rent due (D-3)';

  @override
  String get notifOverdue => 'Rent overdue (D+1)';

  @override
  String get notifPayment => 'Payment confirmed';

  @override
  String get notifBill => 'Bill issued';

  @override
  String get notifLease => 'Lease expiring (D-30)';

  @override
  String get retry => 'Try again';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get loading => 'Loading';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errValidation => 'Some of the information is invalid.';

  @override
  String get errSessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get errPropertyNotFound => 'Property not found.';

  @override
  String get errAccessDenied => 'You don’t have permission to do this.';

  @override
  String get errPropertyInactive =>
      'This property is deactivated and read-only.';

  @override
  String get errManagerNotFound => 'No account exists for that email.';

  @override
  String get errAlreadyHasAccess =>
      'This manager already has access to the property.';

  @override
  String get errLastOwner => 'A property must keep at least one owner.';

  @override
  String get errUnitTypeNotFound => 'Unit type not found.';

  @override
  String get errUnitNotFound => 'Unit not found.';

  @override
  String get errUnitTypeNameTaken =>
      'A unit type with this name already exists.';

  @override
  String get errUnitLabelTaken => 'A unit with this label already exists.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleCoManager => 'Co-manager';

  @override
  String get addProperty => 'Add property';

  @override
  String get addFirstProperty => 'Add my first property';

  @override
  String get editProperty => 'Edit property';

  @override
  String get propertyName => 'Property name';

  @override
  String get propertyAddress => 'Address (optional)';

  @override
  String get propertyCity => 'City (optional)';

  @override
  String get propertySaved => 'Property saved.';

  @override
  String get deactivateProperty => 'Deactivate property';

  @override
  String get deactivateConfirmTitle => 'Deactivate this property?';

  @override
  String get deactivateConfirmBody =>
      'It becomes read-only and disappears from your list. Data is kept.';

  @override
  String get propertyDeactivated => 'Property deactivated.';

  @override
  String unitsOccupied(int occupied, int total) {
    return '$occupied/$total occupied';
  }

  @override
  String get noUnitsYet => 'No units';

  @override
  String get tabUnits => 'Units';

  @override
  String get tabUnitTypes => 'Types';

  @override
  String get tabTeam => 'Team';

  @override
  String get addUnit => 'Add unit';

  @override
  String get editUnit => 'Edit unit';

  @override
  String get unitLabel => 'Number or name (e.g. A1)';

  @override
  String get unitType => 'Unit type';

  @override
  String get noUnitsTitle => 'No units yet';

  @override
  String get noUnitsBody =>
      'Add the apartments, rooms or shops in this property.';

  @override
  String get createTypeFirstTitle => 'Create a unit type first';

  @override
  String get createTypeFirstBody =>
      'A type sets the number of rooms and the base rent. Open the “Types” tab.';

  @override
  String get statusVacant => 'Vacant';

  @override
  String get statusOccupied => 'Occupied';

  @override
  String get unitSaved => 'Unit saved.';

  @override
  String get addUnitType => 'Add type';

  @override
  String get editUnitType => 'Edit type';

  @override
  String get unitTypeName => 'Type name (e.g. Studio)';

  @override
  String get roomCount => 'Number of rooms';

  @override
  String get baseRent => 'Base rent (XAF)';

  @override
  String roomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
    );
    return '$_temp0';
  }

  @override
  String get noUnitTypesTitle => 'No unit types yet';

  @override
  String get noUnitTypesBody =>
      'Define categories (studio, 2-room…) with a base rent.';

  @override
  String get deactivateUnitType => 'Deactivate this type';

  @override
  String get unitTypeSaved => 'Type saved.';

  @override
  String get unitTypeDeactivated => 'Type deactivated.';

  @override
  String get deactivateTypeBody =>
      'Existing units keep it, but it can’t be chosen for new units.';

  @override
  String get inviteManager => 'Invite a manager';

  @override
  String get inviteEmailHelp => 'They must already have a HausMaster account.';

  @override
  String get inviteRole => 'Role';

  @override
  String get invite => 'Invite';

  @override
  String get inviteSent => 'Access granted.';

  @override
  String get removeAccess => 'Remove access';

  @override
  String get removeAccessTitle => 'Remove this access?';

  @override
  String get removeAccessBody =>
      'This person will no longer see this property.';

  @override
  String get accessRemoved => 'Access removed.';

  @override
  String get you => 'you';

  @override
  String get positiveNumber => 'Invalid number';
}
