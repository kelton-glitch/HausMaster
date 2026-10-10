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
  /// **'Bienvenue'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer vos propriétés, locataires et loyers.'**
  String get loginSubtitle;

  /// No description provided for @authTagline.
  ///
  /// In fr, this message translates to:
  /// **'La gestion locative simplifiée pour le Cameroun'**
  String get authTagline;

  /// No description provided for @newToApp.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau sur HausMaster ?'**
  String get newToApp;

  /// No description provided for @createManagerAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte gérant'**
  String get createManagerAccount;

  /// No description provided for @languageSwitch.
  ///
  /// In fr, this message translates to:
  /// **'Langue : Français (FR)'**
  String get languageSwitch;

  /// No description provided for @languageSwitchHint.
  ///
  /// In fr, this message translates to:
  /// **'Passer en anglais'**
  String get languageSwitchHint;

  /// No description provided for @propertiesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 propriété} other{{count} propriétés}}'**
  String propertiesCount(int count);

  /// No description provided for @unitsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 unité} other{{count} unités}}'**
  String unitsCount(int count);

  /// No description provided for @propertiesHeading.
  ///
  /// In fr, this message translates to:
  /// **'Vos propriétés'**
  String get propertiesHeading;

  /// No description provided for @occupancyRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux d’occupation'**
  String get occupancyRate;

  /// No description provided for @searchProperties.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par nom ou ville…'**
  String get searchProperties;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAll;

  /// No description provided for @filterOccupied.
  ///
  /// In fr, this message translates to:
  /// **'Occupées'**
  String get filterOccupied;

  /// No description provided for @filterVacant.
  ///
  /// In fr, this message translates to:
  /// **'Vacantes'**
  String get filterVacant;

  /// No description provided for @occupancyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Occupation'**
  String get occupancyLabel;

  /// No description provided for @viewProperty.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get viewProperty;

  /// No description provided for @noResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre nom ou un autre filtre.'**
  String get noResultsBody;

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

  /// Marks a deactivated tenant
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get statusInactive;

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

  /// No description provided for @tabLeases.
  ///
  /// In fr, this message translates to:
  /// **'Baux'**
  String get tabLeases;

  /// No description provided for @tabTenants.
  ///
  /// In fr, this message translates to:
  /// **'Locataires'**
  String get tabTenants;

  /// No description provided for @addTenant.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un locataire'**
  String get addTenant;

  /// No description provided for @editTenant.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le locataire'**
  String get editTenant;

  /// No description provided for @tenantFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get tenantFullName;

  /// No description provided for @tenantPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get tenantPhone;

  /// No description provided for @tenantEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail (facultatif)'**
  String get tenantEmail;

  /// No description provided for @tenantNationalId.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d’identité (facultatif)'**
  String get tenantNationalId;

  /// No description provided for @tenantEmergencyContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact d’urgence (facultatif)'**
  String get tenantEmergencyContact;

  /// No description provided for @tenantSaved.
  ///
  /// In fr, this message translates to:
  /// **'Locataire enregistré.'**
  String get tenantSaved;

  /// No description provided for @tenantDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Locataire désactivé.'**
  String get tenantDeactivated;

  /// No description provided for @deactivateTenant.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver ce locataire'**
  String get deactivateTenant;

  /// No description provided for @deactivateTenantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver ce locataire ?'**
  String get deactivateTenantTitle;

  /// No description provided for @deactivateTenantBody.
  ///
  /// In fr, this message translates to:
  /// **'Il conserve ses baux et son historique, mais ne pourra plus signer de nouveau bail.'**
  String get deactivateTenantBody;

  /// No description provided for @noTenantsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun locataire'**
  String get noTenantsTitle;

  /// No description provided for @noTenantsBody.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez les personnes qui occupent vos logements.'**
  String get noTenantsBody;

  /// No description provided for @errTenantNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Locataire introuvable.'**
  String get errTenantNotFound;

  /// No description provided for @errTenantPhoneTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro est déjà utilisé par un autre locataire.'**
  String get errTenantPhoneTaken;

  /// No description provided for @addLease.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un bail'**
  String get addLease;

  /// No description provided for @leaseUnit.
  ///
  /// In fr, this message translates to:
  /// **'Logement à louer'**
  String get leaseUnit;

  /// No description provided for @leaseTenant.
  ///
  /// In fr, this message translates to:
  /// **'Locataire'**
  String get leaseTenant;

  /// No description provided for @leaseStartDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get leaseStartDate;

  /// No description provided for @leaseEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get leaseEndDate;

  /// No description provided for @leaseMonthlyRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer mensuel (XAF)'**
  String get leaseMonthlyRent;

  /// No description provided for @leaseRentLockedHint.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillé à la signature du bail'**
  String get leaseRentLockedHint;

  /// No description provided for @leaseSaved.
  ///
  /// In fr, this message translates to:
  /// **'Bail enregistré.'**
  String get leaseSaved;

  /// No description provided for @leaseTerminated.
  ///
  /// In fr, this message translates to:
  /// **'Bail résilié. Le logement est de nouveau vacant.'**
  String get leaseTerminated;

  /// No description provided for @leaseExpiring.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt échu'**
  String get leaseExpiring;

  /// No description provided for @terminateLease.
  ///
  /// In fr, this message translates to:
  /// **'Résilier le bail'**
  String get terminateLease;

  /// No description provided for @terminateLeaseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résilier ce bail ?'**
  String get terminateLeaseTitle;

  /// No description provided for @terminateLeaseBody.
  ///
  /// In fr, this message translates to:
  /// **'Le logement devient vacant. Pour changer le loyer plus tard, signez un nouveau bail.'**
  String get terminateLeaseBody;

  /// No description provided for @noLeasesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bail'**
  String get noLeasesTitle;

  /// No description provided for @noLeasesBody.
  ///
  /// In fr, this message translates to:
  /// **'Signez un bail pour lier un locataire à un logement et suivre le loyer.'**
  String get noLeasesBody;

  /// No description provided for @errLeaseNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bail introuvable.'**
  String get errLeaseNotFound;

  /// No description provided for @errLeaseAlreadyTerminated.
  ///
  /// In fr, this message translates to:
  /// **'Ce bail a déjà été résilié.'**
  String get errLeaseAlreadyTerminated;

  /// No description provided for @errUnitAlreadyLeased.
  ///
  /// In fr, this message translates to:
  /// **'Ce logement a déjà un bail en cours. Résiliez-le d’abord.'**
  String get errUnitAlreadyLeased;

  /// No description provided for @errEndBeforeStart.
  ///
  /// In fr, this message translates to:
  /// **'La date de fin doit être postérieure à la date de début.'**
  String get errEndBeforeStart;

  /// No description provided for @errNoVacantUnit.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un logement vacant avant de signer un bail.'**
  String get errNoVacantUnit;

  /// No description provided for @errNoTenantYet.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez un locataire avant de signer un bail.'**
  String get errNoTenantYet;

  /// A lease date, e.g. 3 Oct 2026
  ///
  /// In fr, this message translates to:
  /// **'{date, date, ::yMMMd}'**
  String leaseDate(DateTime date);

  /// No description provided for @tabBills.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get tabBills;

  /// No description provided for @tabPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get tabPayments;

  /// No description provided for @tabLedger.
  ///
  /// In fr, this message translates to:
  /// **'Grand Livre'**
  String get tabLedger;

  /// No description provided for @tabReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get tabReports;

  /// No description provided for @tabNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get tabNotifications;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboardTitle;

  /// No description provided for @totalProperties.
  ///
  /// In fr, this message translates to:
  /// **'Biens totaux'**
  String get totalProperties;

  /// No description provided for @totalTenants.
  ///
  /// In fr, this message translates to:
  /// **'Locataires'**
  String get totalTenants;

  /// No description provided for @totalUnits.
  ///
  /// In fr, this message translates to:
  /// **'Logements'**
  String get totalUnits;

  /// No description provided for @occupiedUnits.
  ///
  /// In fr, this message translates to:
  /// **'Occupés'**
  String get occupiedUnits;

  /// No description provided for @vacantUnits.
  ///
  /// In fr, this message translates to:
  /// **'Vacants'**
  String get vacantUnits;

  /// No description provided for @upcomingPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements à venir'**
  String get upcomingPayments;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activités récentes'**
  String get recentActivity;

  /// No description provided for @overdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get overdue;

  /// No description provided for @dueSoon.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get dueSoon;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In fr, this message translates to:
  /// **'Impayé'**
  String get unpaid;

  /// No description provided for @partial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get partial;

  /// No description provided for @amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amount;

  /// No description provided for @dueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get dueDate;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @bills.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get bills;

  /// No description provided for @payments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get payments;

  /// No description provided for @ledger.
  ///
  /// In fr, this message translates to:
  /// **'Grand Livre'**
  String get ledger;

  /// No description provided for @reports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reports;

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get viewAll;
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
