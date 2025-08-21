import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'lucid_l10n_en.dart';
import 'lucid_l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LucidL10n
/// returned by `LucidL10n.of(context)`.
///
/// Applications need to include `LucidL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/lucid_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LucidL10n.localizationsDelegates,
///   supportedLocales: LucidL10n.supportedLocales,
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
/// be consistent with the languages listed in the LucidL10n.supportedLocales
/// property.
abstract class LucidL10n {
  LucidL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LucidL10n? of(BuildContext context) {
    return Localizations.of<LucidL10n>(context, LucidL10n);
  }

  static const LocalizationsDelegate<LucidL10n> delegate = _LucidL10nDelegate();

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

  /// Le nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Lucid'**
  String get appName;

  /// Brève description de l'application
  ///
  /// In fr, this message translates to:
  /// **'Une application Flutter puissante avec des fonctionnalités avancées'**
  String get appDescription;

  /// Translation for "ok"
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// Translation for "cancel"
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// Translation for "save"
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// Translation for "delete"
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// Translation for "edit"
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// Translation for "add"
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// Translation for "search"
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// Translation for "filter"
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// Translation for "sort"
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sort;

  /// Translation for "refresh"
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// Translation for "retry"
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// Translation for "back"
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// Translation for "next"
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// Translation for "previous"
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previous;

  /// Translation for "finish"
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// Translation for "close"
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// Translation for "open"
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get open;

  /// Translation for "share"
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// Translation for "copy"
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// Translation for "paste"
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get paste;

  /// Translation for "cut"
  ///
  /// In fr, this message translates to:
  /// **'Couper'**
  String get cut;

  /// Translation for "undo"
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get undo;

  /// Translation for "redo"
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get redo;

  /// Translation for "select"
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get select;

  /// Translation for "selectAll"
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get selectAll;

  /// Translation for "clear"
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// Translation for "reset"
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// Translation for "apply"
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// Translation for "confirm"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// Translation for "submit"
  ///
  /// In fr, this message translates to:
  /// **'Soumettre'**
  String get submit;

  /// Translation for "upload"
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get upload;

  /// Translation for "download"
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// Translation for "import"
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get import;

  /// Translation for "export"
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get export;

  /// Translation for "view"
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// Translation for "preview"
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get preview;

  /// Translation for "send"
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// Translation for "receive"
  ///
  /// In fr, this message translates to:
  /// **'Recevoir'**
  String get receive;

  /// Translation for "loading"
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// Translation for "success"
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// Translation for "error"
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// Translation for "warning"
  ///
  /// In fr, this message translates to:
  /// **'Avertissement'**
  String get warning;

  /// Translation for "info"
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get info;

  /// Translation for "completed"
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get completed;

  /// Translation for "pending"
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// Translation for "cancelled"
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get cancelled;

  /// Translation for "failed"
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get failed;

  /// Translation for "processing"
  ///
  /// In fr, this message translates to:
  /// **'Traitement en cours'**
  String get processing;

  /// Translation for "waiting"
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get waiting;

  /// Translation for "ready"
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get ready;

  /// Translation for "active"
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// Translation for "inactive"
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get inactive;

  /// Translation for "enabled"
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get enabled;

  /// Translation for "disabled"
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get disabled;

  /// Translation for "online"
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// Translation for "offline"
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// Translation for "connected"
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get connected;

  /// Translation for "disconnected"
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get disconnected;

  /// Translation for "syncing"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get syncing;

  /// Translation for "synced"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get synced;

  /// Translation for "expired"
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get expired;

  /// Translation for "valid"
  ///
  /// In fr, this message translates to:
  /// **'Valide'**
  String get valid;

  /// Translation for "invalid"
  ///
  /// In fr, this message translates to:
  /// **'Non valide'**
  String get invalid;

  /// Translation for "home"
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// Translation for "profile"
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// Translation for "settings"
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// Translation for "help"
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get help;

  /// Translation for "about"
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// Translation for "contact"
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Translation for "feedback"
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get feedback;

  /// Translation for "privacy"
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy;

  /// Translation for "terms"
  ///
  /// In fr, this message translates to:
  /// **'Conditions'**
  String get terms;

  /// Translation for "version"
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// Translation for "logout"
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// Translation for "menu"
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Translation for "notifications"
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Translation for "dashboard"
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// Translation for "overview"
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get overview;

  /// Translation for "details"
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// Translation for "history"
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// Translation for "favorites"
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// Translation for "bookmarks"
  ///
  /// In fr, this message translates to:
  /// **'Signets'**
  String get bookmarks;

  /// Translation for "recent"
  ///
  /// In fr, this message translates to:
  /// **'Récent'**
  String get recent;

  /// Translation for "popular"
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get popular;

  /// Translation for "trending"
  ///
  /// In fr, this message translates to:
  /// **'Tendance'**
  String get trending;

  /// Translation for "recommended"
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get recommended;

  /// Translation for "categories"
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categories;

  /// Translation for "tags"
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get tags;

  /// Translation for "login"
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// Translation for "register"
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// Translation for "signup"
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get signup;

  /// Translation for "signin"
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signin;

  /// Translation for "signout"
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signout;

  /// Translation for "email"
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// Translation for "password"
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// Translation for "confirmPassword"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// Translation for "username"
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get username;

  /// Translation for "firstName"
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// Translation for "lastName"
  ///
  /// In fr, this message translates to:
  /// **'Nom de famille'**
  String get lastName;

  /// Translation for "fullName"
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// Translation for "phoneNumber"
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneNumber;

  /// Translation for "dateOfBirth"
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get dateOfBirth;

  /// Translation for "gender"
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get gender;

  /// Translation for "address"
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// Translation for "city"
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// Translation for "country"
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get country;

  /// Translation for "forgotPassword"
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// Translation for "resetPassword"
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPassword;

  /// Translation for "changePassword"
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// Translation for "currentPassword"
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// Translation for "newPassword"
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// Translation for "confirmNewPassword"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get confirmNewPassword;

  /// Translation for "rememberMe"
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get rememberMe;

  /// Translation for "stayLoggedIn"
  ///
  /// In fr, this message translates to:
  /// **'Rester connecté'**
  String get stayLoggedIn;

  /// Translation for "createAccount"
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// Translation for "alreadyHaveAccount"
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get alreadyHaveAccount;

  /// Translation for "dontHaveAccount"
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ?'**
  String get dontHaveAccount;

  /// Translation for "loginWithGoogle"
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Google'**
  String get loginWithGoogle;

  /// Translation for "loginWithFacebook"
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Facebook'**
  String get loginWithFacebook;

  /// Translation for "loginWithApple"
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Apple'**
  String get loginWithApple;

  /// Translation for "or"
  ///
  /// In fr, this message translates to:
  /// **'Ou'**
  String get or;

  /// Translation for "continueWith"
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec'**
  String get continueWith;

  /// Translation for "twoFactorAuth"
  ///
  /// In fr, this message translates to:
  /// **'Authentification à deux facteurs'**
  String get twoFactorAuth;

  /// Translation for "verificationCode"
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get verificationCode;

  /// Translation for "sendCode"
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendCode;

  /// Translation for "resendCode"
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// Translation for "verify"
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verify;

  /// Translation for "accountVerified"
  ///
  /// In fr, this message translates to:
  /// **'Compte vérifié'**
  String get accountVerified;

  /// Translation for "accountSuspended"
  ///
  /// In fr, this message translates to:
  /// **'Compte suspendu'**
  String get accountSuspended;

  /// Translation for "accountLocked"
  ///
  /// In fr, this message translates to:
  /// **'Compte verrouillé'**
  String get accountLocked;

  /// Translation for "sessionExpired"
  ///
  /// In fr, this message translates to:
  /// **'Session expirée'**
  String get sessionExpired;

  /// Translation for "validationError"
  ///
  /// In fr, this message translates to:
  /// **'Erreur de validation'**
  String get validationError;

  /// Translation for "fieldRequired"
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get fieldRequired;

  /// Translation for "invalidEmail"
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir une adresse email valide'**
  String get invalidEmail;

  /// Translation for "invalidPassword"
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe invalide'**
  String get invalidPassword;

  /// Translation for "passwordTooShort"
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est trop court'**
  String get passwordTooShort;

  /// Translation for "passwordTooWeak"
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est trop faible'**
  String get passwordTooWeak;

  /// Translation for "passwordMismatch"
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordMismatch;

  /// Translation for "invalidPhoneNumber"
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un numéro de téléphone valide'**
  String get invalidPhoneNumber;

  /// Translation for "invalidUrl"
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir une URL valide'**
  String get invalidUrl;

  /// Translation for "invalidFormat"
  ///
  /// In fr, this message translates to:
  /// **'Format invalide'**
  String get invalidFormat;

  /// Translation for "valueTooShort"
  ///
  /// In fr, this message translates to:
  /// **'La valeur est trop courte'**
  String get valueTooShort;

  /// Translation for "valueTooLong"
  ///
  /// In fr, this message translates to:
  /// **'La valeur est trop longue'**
  String get valueTooLong;

  /// Translation for "valueOutOfRange"
  ///
  /// In fr, this message translates to:
  /// **'La valeur est hors limites'**
  String get valueOutOfRange;

  /// Translation for "fileTooBig"
  ///
  /// In fr, this message translates to:
  /// **'Le fichier est trop volumineux'**
  String get fileTooBig;

  /// Translation for "unsupportedFileType"
  ///
  /// In fr, this message translates to:
  /// **'Type de fichier non supporté'**
  String get unsupportedFileType;

  /// Translation for "networkError"
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau'**
  String get networkError;

  /// Translation for "connectionTimeout"
  ///
  /// In fr, this message translates to:
  /// **'Délai de connexion dépassé'**
  String get connectionTimeout;

  /// Translation for "noInternetConnection"
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion internet'**
  String get noInternetConnection;

  /// Translation for "serverError"
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur'**
  String get serverError;

  /// Translation for "notFound"
  ///
  /// In fr, this message translates to:
  /// **'Non trouvé'**
  String get notFound;

  /// Translation for "forbidden"
  ///
  /// In fr, this message translates to:
  /// **'Accès interdit'**
  String get forbidden;

  /// Translation for "unauthorized"
  ///
  /// In fr, this message translates to:
  /// **'Accès non autorisé'**
  String get unauthorized;

  /// Translation for "serviceUnavailable"
  ///
  /// In fr, this message translates to:
  /// **'Service indisponible'**
  String get serviceUnavailable;

  /// Translation for "maintenanceMode"
  ///
  /// In fr, this message translates to:
  /// **'Service en maintenance'**
  String get maintenanceMode;

  /// Translation for "somethingWentWrong"
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get somethingWentWrong;

  /// Translation for "tryAgainLater"
  ///
  /// In fr, this message translates to:
  /// **'Veuillez réessayer plus tard'**
  String get tryAgainLater;

  /// Translation for "contactSupport"
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get contactSupport;

  /// No description provided for @fieldMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Minimum {minLength} caractères requis'**
  String fieldMinLength(int minLength);

  /// No description provided for @fieldMaxLength.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {maxLength} caractères autorisés'**
  String fieldMaxLength(int maxLength);

  /// No description provided for @fieldExactLength.
  ///
  /// In fr, this message translates to:
  /// **'Doit contenir exactement {length} caractères'**
  String fieldExactLength(int length);

  /// No description provided for @fileSizeLimit.
  ///
  /// In fr, this message translates to:
  /// **'La taille du fichier ne doit pas dépasser {maxSize}'**
  String fileSizeLimit(String maxSize);

  /// No description provided for @characterLimit.
  ///
  /// In fr, this message translates to:
  /// **'Limite de caractères : {limit}'**
  String characterLimit(int limit);

  /// No description provided for @minimumAge.
  ///
  /// In fr, this message translates to:
  /// **'Âge minimum : {age} ans'**
  String minimumAge(int age);

  /// No description provided for @maximumValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur maximale : {value}'**
  String maximumValue(String value);

  /// No description provided for @minimumValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur minimale : {value}'**
  String minimumValue(String value);

  /// Translation for "today"
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// Translation for "yesterday"
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// Translation for "tomorrow"
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get tomorrow;

  /// Translation for "thisWeek"
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// Translation for "lastWeek"
  ///
  /// In fr, this message translates to:
  /// **'La semaine dernière'**
  String get lastWeek;

  /// Translation for "nextWeek"
  ///
  /// In fr, this message translates to:
  /// **'La semaine prochaine'**
  String get nextWeek;

  /// Translation for "thisMonth"
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// Translation for "lastMonth"
  ///
  /// In fr, this message translates to:
  /// **'Le mois dernier'**
  String get lastMonth;

  /// Translation for "nextMonth"
  ///
  /// In fr, this message translates to:
  /// **'Le mois prochain'**
  String get nextMonth;

  /// Translation for "thisYear"
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get thisYear;

  /// Translation for "lastYear"
  ///
  /// In fr, this message translates to:
  /// **'L\'année dernière'**
  String get lastYear;

  /// Translation for "nextYear"
  ///
  /// In fr, this message translates to:
  /// **'L\'année prochaine'**
  String get nextYear;

  /// Translation for "now"
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get now;

  /// Translation for "older"
  ///
  /// In fr, this message translates to:
  /// **'Plus ancien'**
  String get older;

  /// Translation for "newer"
  ///
  /// In fr, this message translates to:
  /// **'Plus récent'**
  String get newer;

  /// Translation for "latest"
  ///
  /// In fr, this message translates to:
  /// **'Le plus récent'**
  String get latest;

  /// Translation for "earliest"
  ///
  /// In fr, this message translates to:
  /// **'Le plus ancien'**
  String get earliest;

  /// Translation for "second"
  ///
  /// In fr, this message translates to:
  /// **'seconde'**
  String get second;

  /// Translation for "seconds"
  ///
  /// In fr, this message translates to:
  /// **'secondes'**
  String get seconds;

  /// Translation for "minute"
  ///
  /// In fr, this message translates to:
  /// **'minute'**
  String get minute;

  /// Translation for "minutes"
  ///
  /// In fr, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Translation for "hour"
  ///
  /// In fr, this message translates to:
  /// **'heure'**
  String get hour;

  /// Translation for "hours"
  ///
  /// In fr, this message translates to:
  /// **'heures'**
  String get hours;

  /// Translation for "day"
  ///
  /// In fr, this message translates to:
  /// **'jour'**
  String get day;

  /// Translation for "days"
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get days;

  /// Translation for "week"
  ///
  /// In fr, this message translates to:
  /// **'semaine'**
  String get week;

  /// Translation for "weeks"
  ///
  /// In fr, this message translates to:
  /// **'semaines'**
  String get weeks;

  /// Translation for "month"
  ///
  /// In fr, this message translates to:
  /// **'mois'**
  String get month;

  /// Translation for "months"
  ///
  /// In fr, this message translates to:
  /// **'mois'**
  String get months;

  /// Translation for "year"
  ///
  /// In fr, this message translates to:
  /// **'année'**
  String get year;

  /// Translation for "years"
  ///
  /// In fr, this message translates to:
  /// **'années'**
  String get years;

  /// No description provided for @timeAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} {timeUnit}'**
  String timeAgo(int count, String timeUnit);

  /// No description provided for @timeFromNow.
  ///
  /// In fr, this message translates to:
  /// **'dans {count} {timeUnit}'**
  String timeFromNow(int count, String timeUnit);

  /// Translation for "justNow"
  ///
  /// In fr, this message translates to:
  /// **'À l\'instant'**
  String get justNow;

  /// Translation for "inAFewSeconds"
  ///
  /// In fr, this message translates to:
  /// **'Dans quelques secondes'**
  String get inAFewSeconds;

  /// Translation for "aMomentAgo"
  ///
  /// In fr, this message translates to:
  /// **'Il y a un instant'**
  String get aMomentAgo;

  /// Translation for "monday"
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get monday;

  /// Translation for "tuesday"
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get tuesday;

  /// Translation for "wednesday"
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get wednesday;

  /// Translation for "thursday"
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get thursday;

  /// Translation for "friday"
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get friday;

  /// Translation for "saturday"
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get saturday;

  /// Translation for "sunday"
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get sunday;

  /// Translation for "january"
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get january;

  /// Translation for "february"
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get february;

  /// Translation for "march"
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get march;

  /// Translation for "april"
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get april;

  /// Translation for "may"
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get may;

  /// Translation for "june"
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get june;

  /// Translation for "july"
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get july;

  /// Translation for "august"
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get august;

  /// Translation for "september"
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get september;

  /// Translation for "october"
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get october;

  /// Translation for "november"
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get november;

  /// Translation for "december"
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get december;

  /// Translation for "zero"
  ///
  /// In fr, this message translates to:
  /// **'zéro'**
  String get zero;

  /// Translation for "one"
  ///
  /// In fr, this message translates to:
  /// **'un'**
  String get one;

  /// Translation for "two"
  ///
  /// In fr, this message translates to:
  /// **'deux'**
  String get two;

  /// Translation for "few"
  ///
  /// In fr, this message translates to:
  /// **'quelques'**
  String get few;

  /// Translation for "many"
  ///
  /// In fr, this message translates to:
  /// **'plusieurs'**
  String get many;

  /// Translation for "other"
  ///
  /// In fr, this message translates to:
  /// **'autres'**
  String get other;

  /// No description provided for @itemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élément} =1{1 élément} other{{count} éléments}}'**
  String itemCount(int count);

  /// No description provided for @selectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune sélection} =1{1 sélectionné} other{{count} sélectionnés}}'**
  String selectedCount(int count);

  /// No description provided for @totalItems.
  ///
  /// In fr, this message translates to:
  /// **'Total : {total} éléments'**
  String totalItems(int total);

  /// No description provided for @showingResults.
  ///
  /// In fr, this message translates to:
  /// **'Affichage {start}-{end} sur {total}'**
  String showingResults(int start, int end, int total);

  /// No description provided for @pageInfo.
  ///
  /// In fr, this message translates to:
  /// **'Page {current} sur {total}'**
  String pageInfo(int current, int total);

  /// Translation for "language"
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// Translation for "theme"
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// Translation for "lightTheme"
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get lightTheme;

  /// Translation for "darkTheme"
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// Translation for "systemTheme"
  ///
  /// In fr, this message translates to:
  /// **'Thème système'**
  String get systemTheme;

  /// Translation for "pushNotifications"
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get pushNotifications;

  /// Translation for "emailNotifications"
  ///
  /// In fr, this message translates to:
  /// **'Notifications email'**
  String get emailNotifications;

  /// Translation for "soundEnabled"
  ///
  /// In fr, this message translates to:
  /// **'Son activé'**
  String get soundEnabled;

  /// Translation for "vibrationEnabled"
  ///
  /// In fr, this message translates to:
  /// **'Vibration activée'**
  String get vibrationEnabled;

  /// Translation for "autoSync"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique'**
  String get autoSync;

  /// Translation for "dataUsage"
  ///
  /// In fr, this message translates to:
  /// **'Utilisation des données'**
  String get dataUsage;

  /// Translation for "storage"
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get storage;

  /// Translation for "cache"
  ///
  /// In fr, this message translates to:
  /// **'Cache'**
  String get cache;

  /// Translation for "clearCache"
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get clearCache;

  /// Translation for "fontSize"
  ///
  /// In fr, this message translates to:
  /// **'Taille de police'**
  String get fontSize;

  /// Translation for "accessibility"
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get accessibility;

  /// Translation for "highContrast"
  ///
  /// In fr, this message translates to:
  /// **'Contraste élevé'**
  String get highContrast;

  /// Translation for "screenReader"
  ///
  /// In fr, this message translates to:
  /// **'Lecteur d\'écran'**
  String get screenReader;

  /// Translation for "reduceMotion"
  ///
  /// In fr, this message translates to:
  /// **'Réduire les mouvements'**
  String get reduceMotion;

  /// Translation for "security"
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get security;

  /// Translation for "biometric"
  ///
  /// In fr, this message translates to:
  /// **'Biométrie'**
  String get biometric;

  /// Translation for "fingerprint"
  ///
  /// In fr, this message translates to:
  /// **'Empreinte digitale'**
  String get fingerprint;

  /// Translation for "faceId"
  ///
  /// In fr, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// Translation for "pinCode"
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get pinCode;

  /// Translation for "autoLock"
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage automatique'**
  String get autoLock;

  /// Translation for "backup"
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get backup;

  /// Translation for "restore"
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get restore;

  /// Translation for "sync"
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get sync;

  /// Translation for "resetSettings"
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les paramètres'**
  String get resetSettings;

  /// Translation for "defaultSettings"
  ///
  /// In fr, this message translates to:
  /// **'Paramètres par défaut'**
  String get defaultSettings;

  /// Translation for "photo"
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get photo;

  /// Translation for "photos"
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Translation for "image"
  ///
  /// In fr, this message translates to:
  /// **'Image'**
  String get image;

  /// Translation for "images"
  ///
  /// In fr, this message translates to:
  /// **'Images'**
  String get images;

  /// Translation for "video"
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get video;

  /// Translation for "videos"
  ///
  /// In fr, this message translates to:
  /// **'Vidéos'**
  String get videos;

  /// Translation for "audio"
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Translation for "document"
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get document;

  /// Translation for "documents"
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get documents;

  /// Translation for "file"
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get file;

  /// Translation for "files"
  ///
  /// In fr, this message translates to:
  /// **'Fichiers'**
  String get files;

  /// Translation for "folder"
  ///
  /// In fr, this message translates to:
  /// **'Dossier'**
  String get folder;

  /// Translation for "folders"
  ///
  /// In fr, this message translates to:
  /// **'Dossiers'**
  String get folders;

  /// Translation for "gallery"
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get gallery;

  /// Translation for "camera"
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get camera;

  /// Translation for "microphone"
  ///
  /// In fr, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// Translation for "recording"
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement'**
  String get recording;

  /// Translation for "playback"
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get playback;

  /// Translation for "duration"
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get duration;

  /// Translation for "size"
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get size;

  /// Translation for "format"
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get format;

  /// Translation for "quality"
  ///
  /// In fr, this message translates to:
  /// **'Qualité'**
  String get quality;

  /// Translation for "resolution"
  ///
  /// In fr, this message translates to:
  /// **'Résolution'**
  String get resolution;

  /// Translation for "takePhoto"
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// Translation for "recordVideo"
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer une vidéo'**
  String get recordVideo;

  /// Translation for "selectFromGallery"
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner depuis la galerie'**
  String get selectFromGallery;

  /// Translation for "chooseFile"
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get chooseFile;

  /// Translation for "uploadFile"
  ///
  /// In fr, this message translates to:
  /// **'Télécharger un fichier'**
  String get uploadFile;

  /// Translation for "downloadFile"
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le fichier'**
  String get downloadFile;

  /// Translation for "deleteFile"
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le fichier'**
  String get deleteFile;

  /// Translation for "renameFile"
  ///
  /// In fr, this message translates to:
  /// **'Renommer le fichier'**
  String get renameFile;

  /// Translation for "moveFile"
  ///
  /// In fr, this message translates to:
  /// **'Déplacer le fichier'**
  String get moveFile;

  /// Translation for "copyFile"
  ///
  /// In fr, this message translates to:
  /// **'Copier le fichier'**
  String get copyFile;

  /// Translation for "shareFile"
  ///
  /// In fr, this message translates to:
  /// **'Partager le fichier'**
  String get shareFile;

  /// Translation for "confirmAction"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'action'**
  String get confirmAction;

  /// Translation for "areYouSure"
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr ?'**
  String get areYouSure;

  /// Translation for "thisActionCannotBeUndone"
  ///
  /// In fr, this message translates to:
  /// **'Cette action ne peut pas être annulée'**
  String get thisActionCannotBeUndone;

  /// Translation for "confirmDelete"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get confirmDelete;

  /// Translation for "confirmLogout"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la déconnexion'**
  String get confirmLogout;

  /// Translation for "confirmExit"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la sortie'**
  String get confirmExit;

  /// Translation for "confirmCancel"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'annulation'**
  String get confirmCancel;

  /// Translation for "confirmClear"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'effacement'**
  String get confirmClear;

  /// Translation for "confirmReset"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la réinitialisation'**
  String get confirmReset;

  /// Translation for "confirmOverwrite"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'écrasement'**
  String get confirmOverwrite;

  /// Translation for "confirmDiscard"
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'abandon'**
  String get confirmDiscard;

  /// Translation for "unsavedChanges"
  ///
  /// In fr, this message translates to:
  /// **'Modifications non enregistrées'**
  String get unsavedChanges;

  /// Translation for "saveChanges"
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// Translation for "discardChanges"
  ///
  /// In fr, this message translates to:
  /// **'Abandonner les modifications'**
  String get discardChanges;

  /// Translation for "keepEditing"
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'édition'**
  String get keepEditing;

  /// Translation for "exitWithoutSaving"
  ///
  /// In fr, this message translates to:
  /// **'Quitter sans enregistrer'**
  String get exitWithoutSaving;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer \"{itemName}\" ?'**
  String confirmDeleteItem(String itemName);

  /// No description provided for @confirmDeleteItems.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer {count} éléments ?'**
  String confirmDeleteItems(int count);

  /// Translation for "searchHint"
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get searchHint;

  /// Translation for "searchResults"
  ///
  /// In fr, this message translates to:
  /// **'Résultats de recherche'**
  String get searchResults;

  /// Translation for "noResults"
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResults;

  /// Translation for "noResultsFound"
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get noResultsFound;

  /// Translation for "searchSuggestions"
  ///
  /// In fr, this message translates to:
  /// **'Suggestions de recherche'**
  String get searchSuggestions;

  /// Translation for "recentSearches"
  ///
  /// In fr, this message translates to:
  /// **'Recherches récentes'**
  String get recentSearches;

  /// Translation for "clearSearchHistory"
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'historique de recherche'**
  String get clearSearchHistory;

  /// Translation for "advancedSearch"
  ///
  /// In fr, this message translates to:
  /// **'Recherche avancée'**
  String get advancedSearch;

  /// Translation for "filterBy"
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par'**
  String get filterBy;

  /// Translation for "sortBy"
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get sortBy;

  /// Translation for "ascending"
  ///
  /// In fr, this message translates to:
  /// **'Croissant'**
  String get ascending;

  /// Translation for "descending"
  ///
  /// In fr, this message translates to:
  /// **'Décroissant'**
  String get descending;

  /// Translation for "relevance"
  ///
  /// In fr, this message translates to:
  /// **'Pertinence'**
  String get relevance;

  /// Translation for "popularity"
  ///
  /// In fr, this message translates to:
  /// **'Popularité'**
  String get popularity;

  /// Translation for "alphabetical"
  ///
  /// In fr, this message translates to:
  /// **'Alphabétique'**
  String get alphabetical;

  /// Translation for "chronological"
  ///
  /// In fr, this message translates to:
  /// **'Chronologique'**
  String get chronological;

  /// Translation for "applyFilters"
  ///
  /// In fr, this message translates to:
  /// **'Appliquer les filtres'**
  String get applyFilters;

  /// Translation for "clearFilters"
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// Translation for "showAll"
  ///
  /// In fr, this message translates to:
  /// **'Tout afficher'**
  String get showAll;

  /// Translation for "hideFilters"
  ///
  /// In fr, this message translates to:
  /// **'Masquer les filtres'**
  String get hideFilters;

  /// Translation for "moreFilters"
  ///
  /// In fr, this message translates to:
  /// **'Plus de filtres'**
  String get moreFilters;

  /// No description provided for @searchResultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchResultsFor.
  ///
  /// In fr, this message translates to:
  /// **'Résultats de recherche pour \"{query}\"'**
  String searchResultsFor(String query);

  /// Translation for "checkingConnection"
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la connexion...'**
  String get checkingConnection;

  /// Translation for "connectingToServer"
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur...'**
  String get connectingToServer;

  /// Translation for "connectionEstablished"
  ///
  /// In fr, this message translates to:
  /// **'Connexion établie'**
  String get connectionEstablished;

  /// Translation for "connectionLost"
  ///
  /// In fr, this message translates to:
  /// **'Connexion perdue'**
  String get connectionLost;

  /// Translation for "reconnecting"
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion...'**
  String get reconnecting;

  /// Translation for "syncInProgress"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get syncInProgress;

  /// Translation for "syncCompleted"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation terminée'**
  String get syncCompleted;

  /// Translation for "syncFailed"
  ///
  /// In fr, this message translates to:
  /// **'Échec de la synchronisation'**
  String get syncFailed;

  /// Translation for "lastSyncAt"
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation à'**
  String get lastSyncAt;

  /// Translation for "neverSynced"
  ///
  /// In fr, this message translates to:
  /// **'Jamais synchronisé'**
  String get neverSynced;

  /// Translation for "manualSync"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation manuelle'**
  String get manualSync;

  /// Translation for "autoSyncEnabled"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique activée'**
  String get autoSyncEnabled;

  /// Translation for "autoSyncDisabled"
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique désactivée'**
  String get autoSyncDisabled;

  /// Translation for "offlineMode"
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get offlineMode;

  /// Translation for "onlineMode"
  ///
  /// In fr, this message translates to:
  /// **'Mode en ligne'**
  String get onlineMode;

  /// Translation for "dataWillSyncWhenOnline"
  ///
  /// In fr, this message translates to:
  /// **'Les données se synchroniseront en ligne'**
  String get dataWillSyncWhenOnline;

  /// No description provided for @lastSyncTime.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation : {time}'**
  String lastSyncTime(String time);

  /// Translation for "optimizing"
  ///
  /// In fr, this message translates to:
  /// **'Optimisation...'**
  String get optimizing;

  /// Translation for "optimizationComplete"
  ///
  /// In fr, this message translates to:
  /// **'Optimisation terminée'**
  String get optimizationComplete;

  /// Translation for "lowMemoryWarning"
  ///
  /// In fr, this message translates to:
  /// **'Avertissement mémoire faible'**
  String get lowMemoryWarning;

  /// Translation for "diskSpaceWarning"
  ///
  /// In fr, this message translates to:
  /// **'Avertissement espace disque faible'**
  String get diskSpaceWarning;

  /// Translation for "improvingPerformance"
  ///
  /// In fr, this message translates to:
  /// **'Amélioration des performances...'**
  String get improvingPerformance;

  /// Translation for "reducingDataUsage"
  ///
  /// In fr, this message translates to:
  /// **'Réduction de l\'utilisation des données...'**
  String get reducingDataUsage;

  /// Translation for "enableDataSaver"
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'économiseur de données'**
  String get enableDataSaver;

  /// Translation for "highQualityMode"
  ///
  /// In fr, this message translates to:
  /// **'Mode haute qualité'**
  String get highQualityMode;

  /// Translation for "batteryOptimization"
  ///
  /// In fr, this message translates to:
  /// **'Optimisation de la batterie'**
  String get batteryOptimization;

  /// Translation for "powerSavingMode"
  ///
  /// In fr, this message translates to:
  /// **'Mode économie d\'énergie'**
  String get powerSavingMode;

  /// Translation for "performanceMode"
  ///
  /// In fr, this message translates to:
  /// **'Mode performance'**
  String get performanceMode;

  /// Translation for "closeButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton fermer'**
  String get closeButton;

  /// Translation for "backButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton retour'**
  String get backButton;

  /// Translation for "menuButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton menu'**
  String get menuButton;

  /// Translation for "searchButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton recherche'**
  String get searchButton;

  /// Translation for "refreshButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton actualiser'**
  String get refreshButton;

  /// Translation for "loadingIndicator"
  ///
  /// In fr, this message translates to:
  /// **'Indicateur de chargement'**
  String get loadingIndicator;

  /// Translation for "errorMessage"
  ///
  /// In fr, this message translates to:
  /// **'Message d\'erreur'**
  String get errorMessage;

  /// Translation for "successMessage"
  ///
  /// In fr, this message translates to:
  /// **'Message de succès'**
  String get successMessage;

  /// Translation for "warningMessage"
  ///
  /// In fr, this message translates to:
  /// **'Message d\'avertissement'**
  String get warningMessage;

  /// Translation for "infoMessage"
  ///
  /// In fr, this message translates to:
  /// **'Message d\'information'**
  String get infoMessage;

  /// Translation for "expandButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton développer'**
  String get expandButton;

  /// Translation for "collapseButton"
  ///
  /// In fr, this message translates to:
  /// **'Bouton réduire'**
  String get collapseButton;

  /// Translation for "showMore"
  ///
  /// In fr, this message translates to:
  /// **'Afficher plus'**
  String get showMore;

  /// Translation for "showLess"
  ///
  /// In fr, this message translates to:
  /// **'Afficher moins'**
  String get showLess;

  /// Translation for "toggleVisibility"
  ///
  /// In fr, this message translates to:
  /// **'Basculer la visibilité'**
  String get toggleVisibility;

  /// Translation for "openInNewTab"
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans un nouvel onglet'**
  String get openInNewTab;

  /// Translation for "copyToClipboard"
  ///
  /// In fr, this message translates to:
  /// **'Copier dans le presse-papiers'**
  String get copyToClipboard;

  /// Translation for "copiedToClipboard"
  ///
  /// In fr, this message translates to:
  /// **'Copié dans le presse-papiers'**
  String get copiedToClipboard;

  /// No description provided for @buttonDescription.
  ///
  /// In fr, this message translates to:
  /// **'Bouton {buttonName}'**
  String buttonDescription(String buttonName);

  /// No description provided for @inputFieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Champ de saisie {fieldName}'**
  String inputFieldDescription(String fieldName);

  /// No description provided for @selectedOption.
  ///
  /// In fr, this message translates to:
  /// **'{option} sélectionné'**
  String selectedOption(String option);

  /// No description provided for @optionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'{option} indisponible'**
  String optionUnavailable(String option);
}

class _LucidL10nDelegate extends LocalizationsDelegate<LucidL10n> {
  const _LucidL10nDelegate();

  @override
  Future<LucidL10n> load(Locale locale) {
    return SynchronousFuture<LucidL10n>(lookupLucidL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_LucidL10nDelegate old) => false;
}

LucidL10n lookupLucidL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LucidL10nEn();
    case 'fr':
      return LucidL10nFr();
  }

  throw FlutterError(
    'LucidL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
