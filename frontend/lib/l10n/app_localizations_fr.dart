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
  String get passwordWithHint => 'Mot de passe';

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
  String get haveAccount => 'J’ai déjà un compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String welcome(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous pour gérer vos locations.';

  @override
  String get registerSubtitle =>
      'Suivez loyers, locataires et factures au même endroit.';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get passwordRuleLength => 'Au moins 8 caractères';

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

  @override
  String get tabDashboard => 'Accueil';

  @override
  String get tabProperties => 'Biens';

  @override
  String get tabRent => 'Loyers';

  @override
  String get tabProfile => 'Profil';

  @override
  String get gettingStarted => 'Pour commencer';

  @override
  String get stepProperty => 'Ajouter un bien';

  @override
  String get stepTenant => 'Enregistrer un locataire';

  @override
  String get stepLease => 'Créer un bail';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get emptyPropertiesTitle => 'Aucun bien pour l’instant';

  @override
  String get emptyPropertiesBody =>
      'Vos immeubles et logements apparaîtront ici.';

  @override
  String get emptyRentTitle => 'Aucun loyer à suivre';

  @override
  String get emptyRentBody =>
      'Le registre des loyers se remplit dès qu’un bail est créé.';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Auto';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get logoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get logoutConfirmBody =>
      'Vous devrez vous reconnecter pour accéder à vos données.';

  @override
  String get cancel => 'Annuler';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsNote =>
      'L’envoi des notifications sera activé prochainement. Vos choix sont déjà enregistrés.';

  @override
  String get notifRentDue => 'Loyer à échéance (J-3)';

  @override
  String get notifOverdue => 'Loyer en retard (J+1)';

  @override
  String get notifPayment => 'Paiement confirmé';

  @override
  String get notifBill => 'Facture émise';

  @override
  String get notifLease => 'Bail bientôt expiré (J-30)';

  @override
  String get retry => 'Réessayer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get loading => 'Chargement';

  @override
  String get errorTitle => 'Un problème est survenu';

  @override
  String get errValidation => 'Certaines informations sont invalides.';

  @override
  String get errSessionExpired => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errPropertyNotFound => 'Bien introuvable.';

  @override
  String get errAccessDenied =>
      'Vous n’avez pas la permission d’effectuer cette action.';

  @override
  String get errPropertyInactive =>
      'Ce bien est désactivé : il est en lecture seule.';

  @override
  String get errManagerNotFound => 'Aucun compte n’existe pour cet email.';

  @override
  String get errAlreadyHasAccess => 'Ce gestionnaire a déjà accès à ce bien.';

  @override
  String get errLastOwner => 'Un bien doit conserver au moins un propriétaire.';

  @override
  String get errUnitTypeNotFound => 'Type de logement introuvable.';

  @override
  String get errUnitNotFound => 'Logement introuvable.';

  @override
  String get errUnitTypeNameTaken => 'Un type de logement porte déjà ce nom.';

  @override
  String get errUnitLabelTaken => 'Un logement porte déjà ce numéro.';

  @override
  String get roleOwner => 'Propriétaire';

  @override
  String get roleCoManager => 'Co-gestionnaire';

  @override
  String get addProperty => 'Ajouter un bien';

  @override
  String get addFirstProperty => 'Ajouter mon premier bien';

  @override
  String get editProperty => 'Modifier le bien';

  @override
  String get propertyName => 'Nom du bien';

  @override
  String get propertyAddress => 'Adresse (optionnel)';

  @override
  String get propertyCity => 'Ville (optionnel)';

  @override
  String get propertySaved => 'Bien enregistré.';

  @override
  String get deactivateProperty => 'Désactiver le bien';

  @override
  String get deactivateConfirmTitle => 'Désactiver ce bien ?';

  @override
  String get deactivateConfirmBody =>
      'Il passera en lecture seule et disparaîtra de votre liste. Les données sont conservées.';

  @override
  String get propertyDeactivated => 'Bien désactivé.';

  @override
  String unitsOccupied(int occupied, int total) {
    return '$occupied/$total occupés';
  }

  @override
  String get noUnitsYet => 'Aucun logement';

  @override
  String get tabUnits => 'Logements';

  @override
  String get tabUnitTypes => 'Types';

  @override
  String get tabTeam => 'Équipe';

  @override
  String get addUnit => 'Ajouter un logement';

  @override
  String get editUnit => 'Modifier le logement';

  @override
  String get unitLabel => 'Numéro ou nom (ex. A1)';

  @override
  String get unitType => 'Type de logement';

  @override
  String get noUnitsTitle => 'Aucun logement';

  @override
  String get noUnitsBody =>
      'Ajoutez les appartements, chambres ou boutiques de ce bien.';

  @override
  String get createTypeFirstTitle => 'Créez d’abord un type de logement';

  @override
  String get createTypeFirstBody =>
      'Un type définit le nombre de pièces et le loyer de base. Ouvrez l’onglet « Types ».';

  @override
  String get statusVacant => 'Libre';

  @override
  String get statusOccupied => 'Occupé';

  @override
  String get unitSaved => 'Logement enregistré.';

  @override
  String get addUnitType => 'Ajouter un type';

  @override
  String get editUnitType => 'Modifier le type';

  @override
  String get unitTypeName => 'Nom du type (ex. Studio)';

  @override
  String get roomCount => 'Nombre de pièces';

  @override
  String get baseRent => 'Loyer de base (XAF)';

  @override
  String roomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get noUnitTypesTitle => 'Aucun type de logement';

  @override
  String get noUnitTypesBody =>
      'Définissez des catégories (studio, 2 pièces…) avec un loyer de base.';

  @override
  String get deactivateUnitType => 'Désactiver ce type';

  @override
  String get unitTypeSaved => 'Type enregistré.';

  @override
  String get unitTypeDeactivated => 'Type désactivé.';

  @override
  String get deactivateTypeBody =>
      'Les logements existants le conservent, mais il ne pourra plus être choisi pour de nouveaux logements.';

  @override
  String get inviteManager => 'Inviter un gestionnaire';

  @override
  String get inviteEmailHelp =>
      'La personne doit déjà avoir un compte HausMaster.';

  @override
  String get inviteRole => 'Rôle';

  @override
  String get invite => 'Inviter';

  @override
  String get inviteSent => 'Accès accordé.';

  @override
  String get removeAccess => 'Retirer l’accès';

  @override
  String get removeAccessTitle => 'Retirer cet accès ?';

  @override
  String get removeAccessBody => 'Cette personne ne verra plus ce bien.';

  @override
  String get accessRemoved => 'Accès retiré.';

  @override
  String get you => 'vous';

  @override
  String get positiveNumber => 'Nombre invalide';
}
