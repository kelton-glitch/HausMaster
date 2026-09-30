import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @passwordWithHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordWithHint;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @phoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get phoneOptional;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @createMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get createMyAccount;

  /// No description provided for @haveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J’ai déjà un compte'**
  String get haveAccount;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, {name}'**
  String welcome(String name);

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer vos locations.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez loyers, locataires et factures au même endroit.'**
  String get registerSubtitle;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @passwordRuleLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get passwordRuleLength;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get passwordTooShort;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé.'**
  String get errEmailTaken;

  /// No description provided for @errInvalidData.
  ///
  /// In fr, this message translates to:
  /// **'Données invalides (mot de passe : 8 caractères minimum).'**
  String get errInvalidData;

  /// No description provided for @errNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion.'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errGeneric;

  /// No description provided for @tabDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabDashboard;

  /// No description provided for @tabProperties.
  ///
  /// In fr, this message translates to:
  /// **'Biens'**
  String get tabProperties;

  /// No description provided for @tabRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyers'**
  String get tabRent;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @gettingStarted.
  ///
  /// In fr, this message translates to:
  /// **'Pour commencer'**
  String get gettingStarted;

  /// No description provided for @stepProperty.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un bien'**
  String get stepProperty;

  /// No description provided for @stepTenant.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un locataire'**
  String get stepTenant;

  /// No description provided for @stepLease.
  ///
  /// In fr, this message translates to:
  /// **'Créer un bail'**
  String get stepLease;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get comingSoon;

  /// No description provided for @emptyPropertiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bien pour l’instant'**
  String get emptyPropertiesTitle;

  /// No description provided for @emptyPropertiesBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos immeubles et logements apparaîtront ici.'**
  String get emptyPropertiesBody;

  /// No description provided for @emptyRentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun loyer à suivre'**
  String get emptyRentTitle;

  /// No description provided for @emptyRentBody.
  ///
  /// In fr, this message translates to:
  /// **'Le registre des loyers se remplit dès qu’un bail est créé.'**
  String get emptyRentBody;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous devrez vous reconnecter pour accéder à vos données.'**
  String get logoutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsNote.
  ///
  /// In fr, this message translates to:
  /// **'L’envoi des notifications sera activé prochainement. Vos choix sont déjà enregistrés.'**
  String get notificationsNote;

  /// No description provided for @notifRentDue.
  ///
  /// In fr, this message translates to:
  /// **'Loyer à échéance (J-3)'**
  String get notifRentDue;

  /// No description provided for @notifOverdue.
  ///
  /// In fr, this message translates to:
  /// **'Loyer en retard (J+1)'**
  String get notifOverdue;

  /// No description provided for @notifPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement confirmé'**
  String get notifPayment;

  /// No description provided for @notifBill.
  ///
  /// In fr, this message translates to:
  /// **'Facture émise'**
  String get notifBill;

  /// No description provided for @notifLease.
  ///
  /// In fr, this message translates to:
  /// **'Bail bientôt expiré (J-30)'**
  String get notifLease;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un problème est survenu'**
  String get errorTitle;

  /// No description provided for @errValidation.
  ///
  /// In fr, this message translates to:
  /// **'Certaines informations sont invalides.'**
  String get errValidation;

  /// No description provided for @errSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous.'**
  String get errSessionExpired;

  /// No description provided for @errPropertyNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bien introuvable.'**
  String get errPropertyNotFound;

  /// No description provided for @errAccessDenied.
  ///
  /// In fr, this message translates to:
  /// **'Vous n’avez pas la permission d’effectuer cette action.'**
  String get errAccessDenied;

  /// No description provided for @errPropertyInactive.
  ///
  /// In fr, this message translates to:
  /// **'Ce bien est désactivé : il est en lecture seule.'**
  String get errPropertyInactive;

  /// No description provided for @errManagerNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte n’existe pour cet email.'**
  String get errManagerNotFound;

  /// No description provided for @errAlreadyHasAccess.
  ///
  /// In fr, this message translates to:
  /// **'Ce gestionnaire a déjà accès à ce bien.'**
  String get errAlreadyHasAccess;

  /// No description provided for @errLastOwner.
  ///
  /// In fr, this message translates to:
  /// **'Un bien doit conserver au moins un propriétaire.'**
  String get errLastOwner;

  /// No description provided for @errUnitTypeNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Type de logement introuvable.'**
  String get errUnitTypeNotFound;

  /// No description provided for @errUnitNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Logement introuvable.'**
  String get errUnitNotFound;

  /// No description provided for @errUnitTypeNameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Un type de logement porte déjà ce nom.'**
  String get errUnitTypeNameTaken;

  /// No description provided for @errUnitLabelTaken.
  ///
  /// In fr, this message translates to:
  /// **'Un logement porte déjà ce numéro.'**
  String get errUnitLabelTaken;

  /// No description provided for @roleOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get roleOwner;

  /// No description provided for @roleCoManager.
  ///
  /// In fr, this message translates to:
  /// **'Co-gestionnaire'**
  String get roleCoManager;

  /// No description provided for @addProperty.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un bien'**
  String get addProperty;

  /// No description provided for @addFirstProperty.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mon premier bien'**
  String get addFirstProperty;

  /// No description provided for @editProperty.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le bien'**
  String get editProperty;

  /// No description provided for @propertyName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du bien'**
  String get propertyName;

  /// No description provided for @propertyAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse (optionnel)'**
  String get propertyAddress;

  /// No description provided for @propertyCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville (optionnel)'**
  String get propertyCity;

  /// No description provided for @propertySaved.
  ///
  /// In fr, this message translates to:
  /// **'Bien enregistré.'**
  String get propertySaved;

  /// No description provided for @deactivateProperty.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le bien'**
  String get deactivateProperty;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver ce bien ?'**
  String get deactivateConfirmTitle;

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Il passera en lecture seule et disparaîtra de votre liste. Les données sont conservées.'**
  String get deactivateConfirmBody;

  /// No description provided for @propertyDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Bien désactivé.'**
  String get propertyDeactivated;

  /// No description provided for @unitsOccupied.
  ///
  /// In fr, this message translates to:
  /// **'{occupied}/{total} occupés'**
  String unitsOccupied(int occupied, int total);

  /// No description provided for @noUnitsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun logement'**
  String get noUnitsYet;

  /// No description provided for @tabUnits.
  ///
  /// In fr, this message translates to:
  /// **'Logements'**
  String get tabUnits;

  /// No description provided for @tabUnitTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types'**
  String get tabUnitTypes;

  /// No description provided for @tabTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get tabTeam;

  /// No description provided for @addUnit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un logement'**
  String get addUnit;

  /// No description provided for @editUnit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le logement'**
  String get editUnit;

  /// No description provided for @unitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro ou nom (ex. A1)'**
  String get unitLabel;

  /// No description provided for @unitType.
  ///
  /// In fr, this message translates to:
  /// **'Type de logement'**
  String get unitType;

  /// No description provided for @noUnitsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun logement'**
  String get noUnitsTitle;

  /// No description provided for @noUnitsBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les appartements, chambres ou boutiques de ce bien.'**
  String get noUnitsBody;

  /// No description provided for @createTypeFirstTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez d’abord un type de logement'**
  String get createTypeFirstTitle;

  /// No description provided for @createTypeFirstBody.
  ///
  /// In fr, this message translates to:
  /// **'Un type définit le nombre de pièces et le loyer de base. Ouvrez l’onglet « Types ».'**
  String get createTypeFirstBody;

  /// No description provided for @statusVacant.
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get statusVacant;

  /// No description provided for @statusOccupied.
  ///
  /// In fr, this message translates to:
  /// **'Occupé'**
  String get statusOccupied;

  /// No description provided for @unitSaved.
  ///
  /// In fr, this message translates to:
  /// **'Logement enregistré.'**
  String get unitSaved;

  /// No description provided for @addUnitType.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un type'**
  String get addUnitType;

  /// No description provided for @editUnitType.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le type'**
  String get editUnitType;

  /// No description provided for @unitTypeName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du type (ex. Studio)'**
  String get unitTypeName;

  /// No description provided for @roomCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pièces'**
  String get roomCount;

  /// No description provided for @baseRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer de base (XAF)'**
  String get baseRent;

  /// No description provided for @roomsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 pièce} other{{count} pièces}}'**
  String roomsCount(int count);

  /// No description provided for @noUnitTypesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun type de logement'**
  String get noUnitTypesTitle;

  /// No description provided for @noUnitTypesBody.
  ///
  /// In fr, this message translates to:
  /// **'Définissez des catégories (studio, 2 pièces…) avec un loyer de base.'**
  String get noUnitTypesBody;

  /// No description provided for @deactivateUnitType.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver ce type'**
  String get deactivateUnitType;

  /// No description provided for @unitTypeSaved.
  ///
  /// In fr, this message translates to:
  /// **'Type enregistré.'**
  String get unitTypeSaved;

  /// No description provided for @unitTypeDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Type désactivé.'**
  String get unitTypeDeactivated;

  /// No description provided for @deactivateTypeBody.
  ///
  /// In fr, this message translates to:
  /// **'Les logements existants le conservent, mais il ne pourra plus être choisi pour de nouveaux logements.'**
  String get deactivateTypeBody;

  /// No description provided for @inviteManager.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un gestionnaire'**
  String get inviteManager;

  /// No description provided for @inviteEmailHelp.
  ///
  /// In fr, this message translates to:
  /// **'La personne doit déjà avoir un compte HausMaster.'**
  String get inviteEmailHelp;

  /// No description provided for @inviteRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get inviteRole;

  /// No description provided for @invite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get invite;

  /// No description provided for @inviteSent.
  ///
  /// In fr, this message translates to:
  /// **'Accès accordé.'**
  String get inviteSent;

  /// No description provided for @removeAccess.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l’accès'**
  String get removeAccess;

  /// No description provided for @removeAccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cet accès ?'**
  String get removeAccessTitle;

  /// No description provided for @removeAccessBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette personne ne verra plus ce bien.'**
  String get removeAccessBody;

  /// No description provided for @accessRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Accès retiré.'**
  String get accessRemoved;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'vous'**
  String get you;

  /// No description provided for @positiveNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get positiveNumber;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
