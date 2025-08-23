class LucidConstants {
  LucidConstants._();

  // ─────────────────────────────────────────────────────────────
  // APP
  // ─────────────────────────────────────────────────────────────
  static const String defaultAppName = "Lucid Core";
  static const String defaultAppUrl = "lucidcore.example";

  // ─────────────────────────────────────────────────────────────
  // API & Réseau
  // ─────────────────────────────────────────────────────────────
  static const String defaultApiVersion = "1.0.0";
  static const Duration defaultTimeOut = Duration(seconds: 60);
  static const Duration defaultCacheTimeout = Duration(minutes: 5);
  static const Duration defaultRetryInterval = Duration(seconds: 2);
  static const int defaultMaxHttpRetries = 3;
  static const String defaultContentType = "application/json";
  static const String defaultUserAgent = "LucidClient/1.0";

  // ─────────────────────────────────────────────────────────────
  // Stockage local (prefix, groupId)
  // ─────────────────────────────────────────────────────────────
  static const String defaultPrefixKey = "lucid_";
  static const String defaultGroupName = "com.lucidforge.keychain";

  // ─────────────────────────────────────────────────────────────
  // Stockage local (clés de préférences partagées)
  // ─────────────────────────────────────────────────────────────
  static const String defaultSecureStorageKey = "default_lucid_secure_key";
  static const String defaultTokenKey = "default_lucid_auth_token";
  static const String defaultRefreshTokenKey = "default_lucid_refresh_token";
  static const String defaultUserPrefsKey = "default_lucid_user_prefs";
  static const String defaultThemeKey = "default_lucid_theme";
  static const String defaultLocaleKey = "default_lucid_locale";
  static const String defaultFirstLaunchKey = "default_lucid_first_app_launch";
  static const String defaultAnalyticsConsentKey = "default_lucid_analytics_consent";

  // ─────────────────────────────────────────────────────────────
  // Sécurité & Validation
  // ─────────────────────────────────────────────────────────────
  static const int defaultMinPasswordLength = 8;
  static const int defaultMaxPasswordLength = 128;
  static const int defaultMaxUsernameLength = 20;
  static const int defaultOtpLength = 6;
  static const Duration defaultOtpTimeout = Duration(seconds: 120);
  static const int defaultMaxLoginAttempts = 5;

  // ─────────────────────────────────────────────────────────────
  // UI/UX : Animations, Layout & Design System
  // ─────────────────────────────────────────────────────────────
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration defaultLongAnimationDuration = Duration(milliseconds: 500);
  static const Duration defaultDebounceDelay = Duration(milliseconds: 500);
  static const Duration defaultSnackbarDuration = Duration(seconds: 4);

  static const double defaultBorderRadius = 8.0;
  static const double defaultSmallBorderRadius = 4.0;
  static const double defaultLargeBorderRadius = 16.0;

  static const double defaultPadding = 16.0;
  static const double defaultCompactPadding = 8.0;
  static const double defaultExpandedPadding = 24.0;

  static const double defaultMargin = 16.0;
  static const double defaultHorizontalEdge = 16.0;
  static const double defaultVerticalEdge = 8.0;

  static const double defaultElevation = 1.0;
  static const double defaultIconSize = 20.0;

  // ─────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int defaultCompactPageSize = 10;
  static const int defaultExpandedPageSize = 50;
  static const int defaultMaxPageSize = 100;
  static const int defaultInitialPage = 1;

  // ─────────────────────────────────────────────────────────────
  // Formats de date et heure
  // ─────────────────────────────────────────────────────────────
  static const String defaultDateFormat = "yyyy-MM-dd";
  static const String defaultTimeFormat = "HH:mm";
  static const String defaultDateTimeFormat = "yyyy-MM-dd HH:mm:ss";
  static const String humanReadableDateFormat = "EEE, d MMM yyyy";
  static const String humanReadableTimeFormat = "h:mm a";

  // ─────────────────────────────────────────────────────────────
  // Fichiers & Médias
  // ─────────────────────────────────────────────────────────────
  static const double defaultMaxImageUploadSize = 5;
  static const String defaultImageMimeTypes = "image/jpeg,image/png";
  static const String defaultVideoMimeTypes = "video/mp4,video/quicktime";
  static const String defaultDocumentMimeTypes = "application/pdf";
  static const String defaultAssetsPath = "assets/";
  static const String defaultUserContentPath = "user_content/";

  // ─────────────────────────────────────────────────────────────
  // Géolocalisation
  // ─────────────────────────────────────────────────────────────
  static const double defaultMapZoomLevel = 12.0;
  static const double defaultLocationAccuracy = 50;
  static const Duration defaultLocationUpdateInterval = Duration(seconds: 30);
  static const Duration defaultMaxLocationFetchDuration = Duration(seconds: 15);

  // ─────────────────────────────────────────────────────────────
  // Analyse & Surveillance
  // ─────────────────────────────────────────────────────────────
  static const Duration defaultSessionTimeout = Duration(minutes: 15);
  static const Duration defaultInactivityCheckInterval = Duration(seconds: 60);
  static const int defaultLogBufferSize = 1000;
  static const String defaultLogTag = "LUCID";

  // ─────────────────────────────────────────────────────────────
  // Divers utilitaires
  // ─────────────────────────────────────────────────────────────
  static const String defaultCurrencySymbol = "F CFA";
  static const String defaultLocale = "fr_BJ";
  static const String defaultFallbackImage = "";
  static const String defaultCountryCode = "FR";
  static const String defaultCurrencyCode = "XOF";
  static const Duration defaultSplashScreenDuration = Duration(milliseconds: 2000);
}

class LucidErrorCodes {
  LucidErrorCodes._();

  // ─────────────────────────────────────────────────────────────
  // Erreurs Réseau & Connectivité
  // ─────────────────────────────────────────────────────────────
  static const String networkError = "NETWORK_ERROR";
  static const String timeoutError = "TIMEOUT_ERROR";
  static const String noInternetError = "NO_INTERNET_ERROR";
  static const String dnsResolutionFailed = "DNS_RESOLUTION_FAILED";
  static const String sslHandshakeFailed = "SSL_HANDSHAKE_FAILED";
  static const String connectionReset = "CONNECTION_RESET";
  static const String apiRateLimitExceeded = "API_RATE_LIMIT_EXCEEDED";

  // ─────────────────────────────────────────────────────────────
  // Erreurs d'Authentification & Autorisation
  // ─────────────────────────────────────────────────────────────
  static const String invalidCredentials = "INVALID_CREDENTIALS";
  static const String tokenExpired = "TOKEN_EXPIRED";
  static const String unauthorized = "UNAUTHORIZED";
  static const String accountLocked = "ACCOUNT_LOCKED";
  static const String sessionExpired = "SESSION_EXPIRED";
  static const String otpVerificationFailed = "OTP_VERIFICATION_FAILED";
  static const String permissionDenied = "PERMISSION_DENIED";
  static const String twoFactorRequired = "TWO_FACTOR_REQUIRED";
  static const String userSuspended = "USER_SUSPENDED";

  // ─────────────────────────────────────────────────────────────
  // Erreurs de Validation
  // ─────────────────────────────────────────────────────────────
  static const String validationError = "VALIDATION_ERROR";
  static const String requiredField = "REQUIRED_FIELD";
  static const String invalidFormat = "INVALID_FORMAT";
  static const String invalidEmail = "INVALID_EMAIL";
  static const String weakPassword = "WEAK_PASSWORD";
  static const String passwordMismatch = "PASSWORD_MISMATCH";
  static const String outOfRange = "VALUE_OUT_OF_RANGE";
  static const String invalidPhoneNumber = "INVALID_PHONE_NUMBER";
  static const String unsupportedFileType = "UNSUPPORTED_FILE_TYPE";

  // ─────────────────────────────────────────────────────────────
  // Erreurs de Stockage & Persistance
  // ─────────────────────────────────────────────────────────────
  static const String storageError = "STORAGE_ERROR";
  static const String cacheError = "CACHE_ERROR";
  static const String diskFull = "DISK_FULL_ERROR";
  static const String fileNotFound = "FILE_NOT_FOUND";
  static const String databaseLocked = "DATABASE_LOCKED";
  static const String writeFailed = "STORAGE_WRITE_FAILED";
  static const String readFailed = "STORAGE_READ_FAILED";
  static const String clearFailed = "STORAGE_CLEAR_FAILED";
  static const String quotaExceeded = "STORAGE_QUOTA_EXCEEDED";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Serveur & Backend
  // ─────────────────────────────────────────────────────────────
  static const String serverError = "SERVER_ERROR";
  static const String maintenanceMode = "MAINTENANCE_MODE";
  static const String apiDeprecated = "API_DEPRECATED";
  static const String serviceUnavailable = "SERVICE_UNAVAILABLE";
  static const String badGateway = "BAD_GATEWAY";
  static const String internalServerError = "INTERNAL_SERVER_ERROR";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Données & Ressources
  // ─────────────────────────────────────────────────────────────
  static const String dataNotFound = "DATA_NOT_FOUND";
  static const String resourceConflict = "RESOURCE_CONFLICT";
  static const String versionMismatch = "VERSION_MISMATCH";
  static const String dataCorrupted = "DATA_CORRUPTED";
  static const String syncConflict = "SYNC_CONFLICT";
  static const String resourceExpired = "RESOURCE_EXPIRED";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Paiements & Transactions
  // ─────────────────────────────────────────────────────────────
  static const String paymentFailed = "PAYMENT_FAILED";
  static const String insufficientFunds = "INSUFFICIENT_FUNDS";
  static const String cardDeclined = "CARD_DECLINED";
  static const String transactionLimitExceeded = "TRANSACTION_LIMIT_EXCEEDED";
  static const String invalidPaymentToken = "INVALID_PAYMENT_TOKEN";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Médias & Fichiers
  // ─────────────────────────────────────────────────────────────
  static const String mediaUploadFailed = "MEDIA_UPLOAD_FAILED";
  static const String invalidImageFormat = "INVALID_IMAGE_FORMAT";
  static const String fileTooLarge = "FILE_TOO_LARGE";
  static const String videoProcessingError = "VIDEO_PROCESSING_ERROR";
  static const String audioCaptureFailed = "AUDIO_CAPTURE_FAILED";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Géolocalisation
  // ─────────────────────────────────────────────────────────────
  static const String locationDisabled = "LOCATION_DISABLED";
  static const String locationPermissionDenied = "LOCATION_PERMISSION_DENIED";
  static const String geocodingFailed = "GEOCODING_FAILED";
  static const String positionUnavailable = "POSITION_UNAVAILABLE";

  // ─────────────────────────────────────────────────────────────
  // Erreurs Spécifiques Métier
  // ─────────────────────────────────────────────────────────────
  static const String operationNotAllowed = "OPERATION_NOT_ALLOWED";
  static const String subscriptionExpired = "SUBSCRIPTION_EXPIRED";
  static const String userLimitReached = "USER_LIMIT_REACHED";
  static const String contentBlocked = "CONTENT_BLOCKED";
  static const String ageRestriction = "AGE_RESTRICTION";
  static const String licenseInvalid = "LICENSE_INVALID";
}
