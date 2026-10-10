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
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle =>
      'Sign in to manage your properties, tenants and rents.';

  @override
  String get authTagline => 'Simplified rental management for Cameroon';

  @override
  String get newToApp => 'New to HausMaster?';

  @override
  String get createManagerAccount => 'Create a manager account';

  @override
  String get languageSwitch => 'Language: English (EN)';

  @override
  String get languageSwitchHint => 'Switch to French';

  @override
  String propertiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count properties',
      one: '1 property',
    );
    return '$_temp0';
  }

  @override
  String unitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String get propertiesHeading => 'Your properties';

  @override
  String get occupancyRate => 'Occupancy rate';

  @override
  String get searchProperties => 'Search by name or city…';

  @override
  String get filterAll => 'All';

  @override
  String get filterOccupied => 'Occupied';

  @override
  String get filterVacant => 'Vacant';

  @override
  String get occupancyLabel => 'Occupancy';

  @override
  String get viewProperty => 'View';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsBody => 'Try another name or filter.';

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
  String get statusInactive => 'Inactive';

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

  @override
  String get tabLeases => 'Leases';

  @override
  String get tabTenants => 'Tenants';

  @override
  String get addTenant => 'Add tenant';

  @override
  String get editTenant => 'Edit tenant';

  @override
  String get tenantFullName => 'Full name';

  @override
  String get tenantPhone => 'Phone';

  @override
  String get tenantEmail => 'Email (optional)';

  @override
  String get tenantNationalId => 'National ID (optional)';

  @override
  String get tenantEmergencyContact => 'Emergency contact (optional)';

  @override
  String get tenantSaved => 'Tenant saved.';

  @override
  String get tenantDeactivated => 'Tenant deactivated.';

  @override
  String get deactivateTenant => 'Deactivate tenant';

  @override
  String get deactivateTenantTitle => 'Deactivate this tenant?';

  @override
  String get deactivateTenantBody =>
      'They keep their leases and history, but cannot sign a new one.';

  @override
  String get noTenantsTitle => 'No tenants yet';

  @override
  String get noTenantsBody => 'Register the people who live in your units.';

  @override
  String get errTenantNotFound => 'Tenant not found.';

  @override
  String get errTenantPhoneTaken =>
      'This phone number is already used by another tenant.';

  @override
  String get addLease => 'Add lease';

  @override
  String get leaseUnit => 'Unit to rent';

  @override
  String get leaseTenant => 'Tenant';

  @override
  String get leaseStartDate => 'Start date';

  @override
  String get leaseEndDate => 'End date';

  @override
  String get leaseMonthlyRent => 'Monthly rent (XAF)';

  @override
  String get leaseRentLockedHint => 'Locked when the lease is signed';

  @override
  String get leaseSaved => 'Lease signed.';

  @override
  String get leaseTerminated => 'Lease terminated. The unit is vacant again.';

  @override
  String get leaseExpiring => 'Expiring';

  @override
  String get terminateLease => 'Terminate lease';

  @override
  String get terminateLeaseTitle => 'Terminate this lease?';

  @override
  String get terminateLeaseBody =>
      'The unit becomes vacant. To change the rent later, sign a new lease.';

  @override
  String get noLeasesTitle => 'No leases yet';

  @override
  String get noLeasesBody =>
      'Sign a lease to link a tenant to a unit and start tracking rent.';

  @override
  String get errLeaseNotFound => 'Lease not found.';

  @override
  String get errLeaseAlreadyTerminated =>
      'This lease has already been terminated.';

  @override
  String get errUnitAlreadyLeased =>
      'This unit already has an open lease. Terminate it first.';

  @override
  String get errEndBeforeStart => 'The end date must be after the start date.';

  @override
  String get errNoVacantUnit => 'Add a vacant unit before signing a lease.';

  @override
  String get errNoTenantYet => 'Register a tenant before signing a lease.';

  @override
  String leaseDate(DateTime date) {
    String _temp0 = intl.DateFormat.yMMMd(localeName).format(date);
    return '$_temp0';
  }

  @override
  String get tabBills => 'Bills';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabLedger => 'Ledger';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabNotifications => 'Notifications';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get totalProperties => 'Total Properties';

  @override
  String get totalTenants => 'Tenants';

  @override
  String get totalUnits => 'Units';

  @override
  String get occupiedUnits => 'Occupied';

  @override
  String get vacantUnits => 'Vacant';

  @override
  String get upcomingPayments => 'Upcoming Payments';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get overdue => 'Overdue';

  @override
  String get dueSoon => 'Due Soon';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get partial => 'Partial';

  @override
  String get amount => 'Amount';

  @override
  String get dueDate => 'Due Date';

  @override
  String get status => 'Status';

  @override
  String get bills => 'Bills';

  @override
  String get payments => 'Payments';

  @override
  String get ledger => 'Ledger';

  @override
  String get reports => 'Reports';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get viewAll => 'View all';
}
