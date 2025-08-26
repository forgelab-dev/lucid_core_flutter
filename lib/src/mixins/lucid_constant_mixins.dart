import '../core/constants/constants.dart' show LucidConstants;

mixin LucidAppConfigMixin {
  String get appName => LucidConstants.defaultAppName;

  String get appUrl => LucidConstants.defaultAppUrl;

  String get appLocale => LucidConstants.defaultLocale;

  String get appCountryCode => LucidConstants.defaultCountryCode;

  String get appCurrencyCode => LucidConstants.defaultCurrencyCode;

  String get appCurrencySymbol => LucidConstants.defaultCurrencySymbol;

  Duration get appSplashScreenDuration => LucidConstants.defaultSplashScreenDuration;
}

mixin LucidNetworkConfigMixin {
  String get networkApiVersion => LucidConstants.defaultApiVersion;

  String get networkContentType => LucidConstants.defaultContentType;

  String get networkUserAgent => LucidConstants.defaultUserAgent;

  int get networkMaxHttpQueries => LucidConstants.defaultMaxHttpRetries;

  Duration get networkTimeout => LucidConstants.defaultTimeOut;

  Duration get networkCacheTimeout => LucidConstants.defaultCacheTimeout;

  Duration get networkRetryInterval => LucidConstants.defaultRetryInterval;
}

mixin LucidStorageConfigMixin {
  String get storagePrefixKey => LucidConstants.defaultPrefixKey;

  String get storageGroupName => LucidConstants.defaultGroupName;

  String get storageSecureStorageKey => LucidConstants.defaultSecureStorageKey;

  String get storageTokenKey => LucidConstants.defaultTokenKey;

  String get storageRefreshTokenKey => LucidConstants.defaultRefreshTokenKey;

  String get storageUserPrefsKey => LucidConstants.defaultUserPrefsKey;

  String get storageThemeKey => LucidConstants.defaultThemeKey;

  String get storageLocaleKey => LucidConstants.defaultLocaleKey;

  String get storageFirstLaunchKey => LucidConstants.defaultFirstLaunchKey;

  String get storageAnalyticsConsentKey => LucidConstants.defaultAnalyticsConsentKey;
}

mixin LucidSecurityConfigMixin {
  int get securityMinPasswordLength => LucidConstants.defaultMinPasswordLength;

  int get securityMaxPasswordLength => LucidConstants.defaultMaxPasswordLength;

  int get securityMaxUsernameLength => LucidConstants.defaultMaxUsernameLength;

  int get securityOtpLength => LucidConstants.defaultOtpLength;

  int get securityMaxLoginAttempt => LucidConstants.defaultMaxLoginAttempts;

  Duration get securityOtpTimeout => LucidConstants.defaultOtpTimeout;
}

mixin LucidUIConfigMixin {
  double get uiBorderRadius => LucidConstants.defaultBorderRadius;

  double get uiSmallBorderRadius => LucidConstants.defaultSmallBorderRadius;

  double get uiLargeBorderRadius => LucidConstants.defaultLargeBorderRadius;

  double get uiPadding => LucidConstants.defaultPadding;

  double get uiCompactPadding => LucidConstants.defaultCompactPadding;

  double get uiExpandedPadding => LucidConstants.defaultExpandedPadding;

  double get uiMargin => LucidConstants.defaultMargin;

  double get uiHorizontalEdge => LucidConstants.defaultHorizontalEdge;

  double get uiVerticalEdge => LucidConstants.defaultVerticalEdge;

  double get uiElevation => LucidConstants.defaultElevation;

  double get uiIconSize => LucidConstants.defaultIconSize;

  Duration get uiAnimationDuration => LucidConstants.defaultAnimationDuration;

  Duration get uiLongAnimationDuration => LucidConstants.defaultLongAnimationDuration;

  Duration get uiDebounceDelay => LucidConstants.defaultDebounceDelay;

  Duration get uiSnackDuration => LucidConstants.defaultSnackbarDuration;
}

mixin LucidPaginationConfigMixin {
  int get paginationPageSize => LucidConstants.defaultPageSize;

  int get paginationCompactPageSize => LucidConstants.defaultCompactPageSize;

  int get paginationExpandedPageSize => LucidConstants.defaultExpandedPageSize;

  int get paginationMaxPageSize => LucidConstants.defaultMaxPageSize;

  int get paginationInitialPage => LucidConstants.defaultInitialPage;
}

mixin LucidDTConfigMixin {
  String get dtDateFormat => LucidConstants.defaultDateFormat;

  String get dtTimeFormat => LucidConstants.defaultTimeFormat;

  String get dtDateTimeFormat => LucidConstants.defaultDateTimeFormat;

  String get dtHumanReadableDateFormat => LucidConstants.humanReadableDateFormat;

  String get dtHumanReadableTimeFormat => LucidConstants.humanReadableTimeFormat;
}

mixin LucidMediaConfigMixin {
  String get mediaImageMimeTypes => LucidConstants.defaultImageMimeTypes;

  String get mediaVideoMimeTypes => LucidConstants.defaultVideoMimeTypes;

  String get mediaDocumentMimeTypes => LucidConstants.defaultDocumentMimeTypes;

  String get mediaAssetsPath => LucidConstants.defaultAssetsPath;

  String get mediaUserContentPath => LucidConstants.defaultUserContentPath;

  String get mediaFallbackImage => LucidConstants.defaultFallbackImage;

  double get mediaMaxImageUploadSize => LucidConstants.defaultMaxImageUploadSize;
}

mixin LucidLocationConfigMixin {
  double get locationMapZoomLevel => LucidConstants.defaultMapZoomLevel;

  double get locationAccuracy => LucidConstants.defaultLocationAccuracy;

  Duration get locationUpdateInterval => LucidConstants.defaultLocationUpdateInterval;

  Duration get locationMaxFetchDuration => LucidConstants.defaultMaxLocationFetchDuration;
}

mixin LucidAnalyticsConfigMixin {
  String get analyticsLogTag => LucidConstants.defaultLogTag;

  int get analyticsLogBufferSize => LucidConstants.defaultLogBufferSize;

  Duration get analyticsSessionTimeout => LucidConstants.defaultSessionTimeout;

  Duration get analyticsInactivityCheckInterval => LucidConstants.defaultInactivityCheckInterval;
}

mixin LucidConfigMixin
    on
        LucidAppConfigMixin,
        LucidNetworkConfigMixin,
        LucidStorageConfigMixin,
        LucidSecurityConfigMixin,
        LucidUIConfigMixin,
        LucidPaginationConfigMixin,
        LucidDTConfigMixin,
        LucidMediaConfigMixin,
        LucidLocationConfigMixin,
        LucidAnalyticsConfigMixin {}
