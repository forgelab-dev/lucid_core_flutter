import '../core/abstracts/abstracts.dart' show LucidAbstractConfigResolver;
import '../core/constants/constants.dart' show LucidConstants;

mixin LucidAppConfigMixin on LucidAbstractConfigResolver {
  String get appName => resolveConfig('appName', LucidConstants.defaultAppName);

  String get appUrl => resolveConfig('appUrl', LucidConstants.defaultAppUrl);

  String get appLocale => resolveConfig('appLocale', LucidConstants.defaultLocale);

  String get appCountryCode => resolveConfig('appCountryCode', LucidConstants.defaultCountryCode);

  String get appCurrencyCode => resolveConfig('appCurrencyCode', LucidConstants.defaultCurrencyCode);

  String get appCurrencySymbol => resolveConfig('appCurrencySymbol', LucidConstants.defaultCurrencySymbol);

  Duration get appSplashScreenDuration => resolveConfig('appSplashScreenDuration', LucidConstants.defaultSplashScreenDuration);
}

mixin LucidNetworkConfigMixin on LucidAbstractConfigResolver {
  String get networkApiUrl => resolveConfig('networkApiUrl', LucidConstants.defaultApiUrl);

  String get networkApiVersion => resolveConfig('networkApiVersion', LucidConstants.defaultApiVersion);

  String get networkContentType => resolveConfig('networkContentType', LucidConstants.defaultContentType);

  String get networkUserAgent => resolveConfig('networkUserAgent', LucidConstants.defaultUserAgent);

  int get networkMaxHttpQueries => resolveConfig('networkMaxHttpQueries', LucidConstants.defaultMaxHttpRetries);

  Duration get networkTimeout => resolveConfig('networkTimeout', LucidConstants.defaultTimeOut);

  Duration get networkCacheTimeout => resolveConfig('networkCacheTimeout', LucidConstants.defaultCacheTimeout);

  Duration get networkRetryInterval => resolveConfig('networkRetryInterval', LucidConstants.defaultRetryInterval);
}

mixin LucidStorageConfigMixin on LucidAbstractConfigResolver {
  String get storagePrefixKey => resolveConfig('storagePrefixKey', LucidConstants.defaultPrefixKey);

  String get storageGroupName => resolveConfig('storageGroupName', LucidConstants.defaultGroupName);

  String get storageSecureStorageKey => resolveConfig('storageSecureStorageKey', LucidConstants.defaultSecureStorageKey);

  String get storageTokenKey => resolveConfig('storageTokenKey', LucidConstants.defaultTokenKey);

  String get storageRefreshTokenKey => resolveConfig('storageRefreshTokenKey', LucidConstants.defaultRefreshTokenKey);

  String get storageUserPrefsKey => resolveConfig('storageUserPrefsKey', LucidConstants.defaultUserPrefsKey);

  String get storageThemeKey => resolveConfig('storageThemeKey', LucidConstants.defaultThemeKey);

  String get storageLocaleKey => resolveConfig('storageLocaleKey', LucidConstants.defaultLocaleKey);

  String get storageFirstLaunchKey => resolveConfig('storageFirstLaunchKey', LucidConstants.defaultFirstLaunchKey);

  String get storageAnalyticsConsentKey => resolveConfig('storageAnalyticsConsentKey', LucidConstants.defaultAnalyticsConsentKey);
}

mixin LucidSecurityConfigMixin on LucidAbstractConfigResolver {
  int get securityMinPasswordLength => resolveConfig('securityMinPasswordLength', LucidConstants.defaultMinPasswordLength);

  int get securityMaxPasswordLength => resolveConfig('securityMaxPasswordLength', LucidConstants.defaultMaxPasswordLength);

  int get securityMaxUsernameLength => resolveConfig('securityMaxUsernameLength', LucidConstants.defaultMaxUsernameLength);

  int get securityOtpLength => resolveConfig('securityOtpLength', LucidConstants.defaultOtpLength);

  int get securityMaxLoginAttempt => resolveConfig('securityMaxLoginAttempt', LucidConstants.defaultMaxLoginAttempts);

  Duration get securityOtpTimeout => resolveConfig('securityOtpTimeout', LucidConstants.defaultOtpTimeout);
}

mixin LucidUIConfigMixin on LucidAbstractConfigResolver {
  double get uiBorderRadius => resolveConfig('uiBorderRadius', LucidConstants.defaultBorderRadius);

  double get uiSmallBorderRadius => resolveConfig('uiSmallBorderRadius', LucidConstants.defaultSmallBorderRadius);

  double get uiLargeBorderRadius => resolveConfig('uiLargeBorderRadius', LucidConstants.defaultLargeBorderRadius);

  double get uiPadding => resolveConfig('uiPadding', LucidConstants.defaultPadding);

  double get uiCompactPadding => resolveConfig('uiCompactPadding', LucidConstants.defaultCompactPadding);

  double get uiExpandedPadding => resolveConfig('uiExpandedPadding', LucidConstants.defaultExpandedPadding);

  double get uiMargin => resolveConfig('uiMargin', LucidConstants.defaultMargin);

  double get uiHorizontalEdge => resolveConfig('uiHorizontalEdge', LucidConstants.defaultHorizontalEdge);

  double get uiVerticalEdge => resolveConfig('uiVerticalEdge', LucidConstants.defaultVerticalEdge);

  double get uiElevation => resolveConfig('uiElevation', LucidConstants.defaultElevation);

  double get uiIconSize => resolveConfig('uiIconSize', LucidConstants.defaultIconSize);

  Duration get uiAnimationDuration => resolveConfig('uiAnimationDuration', LucidConstants.defaultAnimationDuration);

  Duration get uiLongAnimationDuration => resolveConfig('uiLongAnimationDuration', LucidConstants.defaultLongAnimationDuration);

  Duration get uiDebounceDelay => resolveConfig('uiDebounceDelay', LucidConstants.defaultDebounceDelay);

  Duration get uiSnackDuration => resolveConfig('uiSnackDuration', LucidConstants.defaultSnackbarDuration);
}

mixin LucidPaginationConfigMixin on LucidAbstractConfigResolver {
  int get paginationPageSize => resolveConfig('paginationPageSize', LucidConstants.defaultPageSize);

  int get paginationCompactPageSize => resolveConfig('paginationCompactPageSize', LucidConstants.defaultCompactPageSize);

  int get paginationExpandedPageSize => resolveConfig('paginationExpandedPageSize', LucidConstants.defaultExpandedPageSize);

  int get paginationMaxPageSize => resolveConfig('paginationMaxPageSize', LucidConstants.defaultMaxPageSize);

  int get paginationInitialPage => resolveConfig('paginationInitialPage', LucidConstants.defaultInitialPage);
}

mixin LucidDTConfigMixin on LucidAbstractConfigResolver {
  String get dtDateFormat => resolveConfig('dtDateFormat', LucidConstants.defaultDateFormat);

  String get dtTimeFormat => resolveConfig('dtTimeFormat', LucidConstants.defaultTimeFormat);

  String get dtDateTimeFormat => resolveConfig('dtDateTimeFormat', LucidConstants.defaultDateTimeFormat);

  String get dtHumanReadableDateFormat => resolveConfig('dtHumanReadableDateFormat', LucidConstants.humanReadableDateFormat);

  String get dtHumanReadableTimeFormat => resolveConfig('dtHumanReadableTimeFormat', LucidConstants.humanReadableTimeFormat);
}

mixin LucidMediaConfigMixin on LucidAbstractConfigResolver {
  String get mediaImageMimeTypes => resolveConfig('mediaImageMimeTypes', LucidConstants.defaultImageMimeTypes);

  String get mediaVideoMimeTypes => resolveConfig('mediaVideoMimeTypes', LucidConstants.defaultVideoMimeTypes);

  String get mediaDocumentMimeTypes => resolveConfig('mediaDocumentMimeTypes', LucidConstants.defaultDocumentMimeTypes);

  String get mediaAssetsPath => resolveConfig('mediaAssetsPath', LucidConstants.defaultAssetsPath);

  String get mediaUserContentPath => resolveConfig('mediaUserContentPath', LucidConstants.defaultUserContentPath);

  String get mediaFallbackImage => resolveConfig('mediaFallbackImage', LucidConstants.defaultFallbackImage);

  double get mediaMaxImageUploadSize => resolveConfig('mediaMaxImageUploadSize', LucidConstants.defaultMaxImageUploadSize);
}

mixin LucidLocationConfigMixin on LucidAbstractConfigResolver {
  double get locationMapZoomLevel => resolveConfig('locationMapZoomLevel', LucidConstants.defaultMapZoomLevel);

  double get locationAccuracy => resolveConfig('locationAccuracy', LucidConstants.defaultLocationAccuracy);

  Duration get locationUpdateInterval => resolveConfig('locationUpdateInterval', LucidConstants.defaultLocationUpdateInterval);

  Duration get locationMaxFetchDuration => resolveConfig('locationMaxFetchDuration', LucidConstants.defaultMaxLocationFetchDuration);
}

mixin LucidAnalyticsConfigMixin on LucidAbstractConfigResolver {
  String get analyticsLogTag => resolveConfig('analyticsLogTag', LucidConstants.defaultLogTag);

  int get analyticsLogBufferSize => resolveConfig('analyticsLogBufferSize', LucidConstants.defaultLogBufferSize);

  Duration get analyticsSessionTimeout => resolveConfig('analyticsSessionTimeout', LucidConstants.defaultSessionTimeout);

  Duration get analyticsInactivityCheckInterval => resolveConfig('analyticsInactivityCheckInterval', LucidConstants.defaultInactivityCheckInterval);
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
