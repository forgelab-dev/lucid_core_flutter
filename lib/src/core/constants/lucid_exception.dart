import '../abstracts/abstracts.dart' show LucidAbstractException;
import 'lucid_constants.dart' show LucidErrorCodes;
import 'lucid_enums.dart' show LucidErrorSeverity, LucidStorageOperation;
import 'lucid_typedefs.dart' show LucidJsonMap;

class AuthenticationException extends LucidAbstractException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.context,
    super.severity = LucidErrorSeverity.error,
    super.stackTrace,
    super.timestamp,
    this.requiresReauth = false,
  });

  final bool requiresReauth;

  factory AuthenticationException.invalidCredentials() => const AuthenticationException(
    'Identifiants invalides',
    code: LucidErrorCodes.invalidCredentials,
    severity: LucidErrorSeverity.warning,
  );

  factory AuthenticationException.tokenExpired() => const AuthenticationException(
    'Jeton d\'authentification expiré',
    code: LucidErrorCodes.tokenExpired,
    severity: LucidErrorSeverity.warning,
    requiresReauth: true,
  );

  factory AuthenticationException.sessionExpired() => const AuthenticationException(
    'Session expirée, veuillez vous reconnecter',
    code: LucidErrorCodes.sessionExpired,
    severity: LucidErrorSeverity.warning,
    requiresReauth: true,
  );

  factory AuthenticationException.unauthorized() => const AuthenticationException(
    'Accès non autorisé',
    code: LucidErrorCodes.unauthorized,
    severity: LucidErrorSeverity.error,
  );

  factory AuthenticationException.accountLocked() => const AuthenticationException(
    'Compte verrouillé après plusieurs tentatives',
    code: LucidErrorCodes.accountLocked,
    severity: LucidErrorSeverity.error,
  );

  factory AuthenticationException.userSuspended() => const AuthenticationException(
    'Compte utilisateur suspendu',
    code: LucidErrorCodes.userSuspended,
    severity: LucidErrorSeverity.error,
  );

  factory AuthenticationException.otpVerificationFailed() => const AuthenticationException(
    'Échec de la vérification OTP',
    code: LucidErrorCodes.otpVerificationFailed,
    severity: LucidErrorSeverity.warning,
  );

  factory AuthenticationException.twoFactorRequired() => const AuthenticationException(
    'Authentification à deux facteurs requise',
    code: LucidErrorCodes.twoFactorRequired,
    severity: LucidErrorSeverity.info,
  );

  factory AuthenticationException.permissionDenied() => const AuthenticationException(
    'Permission refusée pour cette opération',
    code: LucidErrorCodes.permissionDenied,
    severity: LucidErrorSeverity.warning,
  );

  @override
  AuthenticationException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    bool? requiresReauth,
  }) {
    return AuthenticationException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      requiresReauth: requiresReauth ?? this.requiresReauth,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map['requiresReauth'] = requiresReauth;
    return map;
  }
}

class BusinessException extends LucidAbstractException {
  const BusinessException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.warning,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.resource,
    this.operation,
  });

  final String? resource;

  final String? operation;

  factory BusinessException.operationNotAllowed({String? operation, String? resource}) => BusinessException(
    'Opération non autorisée${operation != null ? ': $operation' : ''}${resource != null ? ' sur $resource' : ''}',
    code: LucidErrorCodes.operationNotAllowed,
    severity: LucidErrorSeverity.warning,
    operation: operation,
    resource: resource,
  );

  factory BusinessException.subscriptionExpired() => const BusinessException(
    'Abonnement expiré',
    code: LucidErrorCodes.subscriptionExpired,
    severity: LucidErrorSeverity.error,
  );

  factory BusinessException.userLimitReached({int? currentCount, int? maxLimit}) => BusinessException(
    'Limite d\'utilisateurs atteinte${currentCount != null && maxLimit != null ? ' ($currentCount/$maxLimit)' : ''}',
    code: LucidErrorCodes.userLimitReached,
    severity: LucidErrorSeverity.warning,
    context: {if (currentCount != null) 'currentCount': currentCount, if (maxLimit != null) 'maxLimit': maxLimit},
  );

  factory BusinessException.contentBlocked({String? reason}) => BusinessException(
    'Contenu bloqué${reason != null ? ': $reason' : ''}',
    code: LucidErrorCodes.contentBlocked,
    severity: LucidErrorSeverity.warning,
    context: reason != null ? {'reason': reason} : null,
  );

  factory BusinessException.ageRestriction({int? requiredAge, int? userAge}) => BusinessException(
    'Restriction d\'âge${requiredAge != null ? ': $requiredAge ans requis' : ''}${userAge != null && requiredAge != null ? ' (utilisateur: $userAge ans)' : ''}',
    code: LucidErrorCodes.ageRestriction,
    severity: LucidErrorSeverity.warning,
    context: {if (requiredAge != null) 'requiredAge': requiredAge, if (userAge != null) 'userAge': userAge},
  );

  factory BusinessException.licenseInvalid({String? licenseKey}) => BusinessException(
    'Licence invalide${licenseKey != null ? ': $licenseKey' : ''}',
    code: LucidErrorCodes.licenseInvalid,
    severity: LucidErrorSeverity.error,
    context: licenseKey != null ? {'licenseKey': licenseKey} : null,
  );

  factory BusinessException.dataNotFound({String? resource, String? id}) => BusinessException(
    'Données non trouvées${resource != null ? ' ($resource)' : ''}${id != null ? ' ID: $id' : ''}',
    code: LucidErrorCodes.dataNotFound,
    severity: LucidErrorSeverity.warning,
    resource: resource,
    context: id != null ? {'id': id} : null,
  );

  factory BusinessException.resourceConflict({String? resource, String? conflictReason}) => BusinessException(
    'Conflit de ressource${resource != null ? ' ($resource)' : ''}${conflictReason != null ? ': $conflictReason' : ''}',
    code: LucidErrorCodes.resourceConflict,
    severity: LucidErrorSeverity.warning,
    resource: resource,
    context: conflictReason != null ? {'conflictReason': conflictReason} : null,
  );

  factory BusinessException.versionMismatch({String? expectedVersion, String? actualVersion}) => BusinessException(
    'Incompatibilité de version${expectedVersion != null && actualVersion != null ? ' (attendue: $expectedVersion, actuelle: $actualVersion)' : ''}',
    code: LucidErrorCodes.versionMismatch,
    severity: LucidErrorSeverity.error,
    context: {
      if (expectedVersion != null) 'expectedVersion': expectedVersion,
      if (actualVersion != null) 'actualVersion': actualVersion,
    },
  );

  factory BusinessException.syncConflict({String? resource}) => BusinessException(
    'Conflit de synchronisation${resource != null ? ' pour $resource' : ''}',
    code: LucidErrorCodes.syncConflict,
    severity: LucidErrorSeverity.warning,
    resource: resource,
  );

  factory BusinessException.resourceExpired({String? resource, DateTime? expiredAt}) => BusinessException(
    'Ressource expirée${resource != null ? ' ($resource)' : ''}${expiredAt != null ? ' le ${expiredAt.toIso8601String()}' : ''}',
    code: LucidErrorCodes.resourceExpired,
    severity: LucidErrorSeverity.warning,
    resource: resource,
    context: expiredAt != null ? {'expiredAt': expiredAt.toIso8601String()} : null,
  );

  @override
  BusinessException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? resource,
    String? operation,
  }) {
    return BusinessException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      resource: resource ?? this.resource,
      operation: operation ?? this.operation,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'resource': resource, 'operation': operation});
    return map;
  }
}

class CacheException extends LucidAbstractException {
  const CacheException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.warning,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.key,
    this.expirationTime,
  });

  final String? key;

  final DateTime? expirationTime;

  factory CacheException.notFound(String key) => CacheException(
    'Clé non trouvée dans le cache: $key',
    code: 'CACHE_NOT_FOUND',
    severity: LucidErrorSeverity.info,
    key: key,
  );

  factory CacheException.expired(String key, {DateTime? expirationTime}) => CacheException(
    'Cache expiré pour la clé: $key',
    code: 'CACHE_EXPIRED',
    severity: LucidErrorSeverity.info,
    key: key,
    expirationTime: expirationTime,
  );

  factory CacheException.writeError(String key) => CacheException(
    'Erreur d\'écriture dans le cache pour: $key',
    code: LucidErrorCodes.cacheError,
    severity: LucidErrorSeverity.warning,
    key: key,
  );

  factory CacheException.corruptedData(String key) => CacheException(
    'Données corrompues dans le cache pour: $key',
    code: LucidErrorCodes.dataCorrupted,
    severity: LucidErrorSeverity.warning,
    key: key,
  );

  @override
  CacheException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? key,
    DateTime? expirationTime,
  }) {
    return CacheException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      key: key ?? this.key,
      expirationTime: expirationTime ?? this.expirationTime,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'key': key, 'expirationTime': expirationTime?.toIso8601String()});
    return map;
  }
}

class LocationException extends LucidAbstractException {
  const LocationException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.warning,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.latitude,
    this.longitude,
    this.accuracy,
  });

  final double? latitude;

  final double? longitude;

  final double? accuracy;

  factory LocationException.locationDisabled() => const LocationException(
    'Service de géolocalisation désactivé',
    code: LucidErrorCodes.locationDisabled,
    severity: LucidErrorSeverity.warning,
  );

  factory LocationException.permissionDenied() => const LocationException(
    'Permission de géolocalisation refusée',
    code: LucidErrorCodes.locationPermissionDenied,
    severity: LucidErrorSeverity.warning,
  );

  factory LocationException.positionUnavailable() => const LocationException(
    'Position indisponible',
    code: LucidErrorCodes.positionUnavailable,
    severity: LucidErrorSeverity.error,
  );

  factory LocationException.geocodingFailed({String? address}) => LocationException(
    'Échec du géocodage${address != null ? ' pour: $address' : ''}',
    code: LucidErrorCodes.geocodingFailed,
    severity: LucidErrorSeverity.warning,
    context: address != null ? {'address': address} : null,
  );

  @override
  LocationException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) {
    return LocationException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'latitude': latitude, 'longitude': longitude, 'accuracy': accuracy});
    return map;
  }
}

class MediaException extends LucidAbstractException {
  const MediaException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.error,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.fileName,
    this.fileSize,
    this.mimeType,
  });

  final String? fileName;

  final int? fileSize;

  final String? mimeType;

  factory MediaException.uploadFailed({String? fileName}) => MediaException(
    'Échec du téléchargement${fileName != null ? ' de $fileName' : ''}',
    code: LucidErrorCodes.mediaUploadFailed,
    severity: LucidErrorSeverity.error,
    fileName: fileName,
  );

  factory MediaException.invalidImageFormat({String? fileName, String? mimeType}) => MediaException(
    'Format d\'image invalide${fileName != null ? ' pour $fileName' : ''}',
    code: LucidErrorCodes.invalidImageFormat,
    severity: LucidErrorSeverity.warning,
    fileName: fileName,
    mimeType: mimeType,
  );

  factory MediaException.fileTooLarge({String? fileName, int? fileSize, int? maxSize}) => MediaException(
    'Fichier trop volumineux${fileName != null ? ' ($fileName)' : ''}${fileSize != null && maxSize != null ? ': ${fileSize}B > ${maxSize}B' : ''}',
    code: LucidErrorCodes.fileTooLarge,
    severity: LucidErrorSeverity.warning,
    fileName: fileName,
    fileSize: fileSize,
    context: maxSize != null ? {'maxSize': maxSize} : null,
  );

  factory MediaException.videoProcessingError({String? fileName}) => MediaException(
    'Erreur de traitement vidéo${fileName != null ? ' pour $fileName' : ''}',
    code: LucidErrorCodes.videoProcessingError,
    severity: LucidErrorSeverity.error,
    fileName: fileName,
  );

  factory MediaException.audioCaptureFailed() => const MediaException(
    'Échec de la capture audio',
    code: LucidErrorCodes.audioCaptureFailed,
    severity: LucidErrorSeverity.error,
  );

  @override
  MediaException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? fileName,
    int? fileSize,
    String? mimeType,
  }) {
    return MediaException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'fileName': fileName, 'fileSize': fileSize, 'mimeType': mimeType});
    return map;
  }
}

class NetworkException extends LucidAbstractException {
  const NetworkException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.error,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.statusCode,
    this.url,
  });

  final int? statusCode;

  final String? url;

  factory NetworkException.noInternet() => const NetworkException(
    'Aucune connexion internet',
    code: LucidErrorCodes.noInternetError,
    severity: LucidErrorSeverity.error,
  );

  factory NetworkException.timeout() => const NetworkException(
    'Délai d\'attente dépassé',
    code: LucidErrorCodes.timeoutError,
    severity: LucidErrorSeverity.warning,
  );

  factory NetworkException.dnsResolutionFailed() => const NetworkException(
    'Échec de la résolution DNS',
    code: LucidErrorCodes.dnsResolutionFailed,
    severity: LucidErrorSeverity.error,
  );

  factory NetworkException.sslHandshakeFailed() => const NetworkException(
    'Échec de la négociation SSL',
    code: LucidErrorCodes.sslHandshakeFailed,
    severity: LucidErrorSeverity.critical,
  );

  factory NetworkException.connectionReset() => const NetworkException(
    'Connexion réinitialisée par le serveur',
    code: LucidErrorCodes.connectionReset,
    severity: LucidErrorSeverity.warning,
  );

  factory NetworkException.rateLimitExceeded() => const NetworkException(
    'Limite de taux d\'API dépassée',
    code: LucidErrorCodes.apiRateLimitExceeded,
    severity: LucidErrorSeverity.warning,
  );

  factory NetworkException.serverError(int statusCode, {String? url}) => NetworkException(
    'Erreur serveur: $statusCode',
    code: 'SERVER_ERROR_$statusCode',
    severity: statusCode >= 500 ? LucidErrorSeverity.error : LucidErrorSeverity.warning,
    statusCode: statusCode,
    url: url,
  );

  factory NetworkException.badGateway() => const NetworkException(
    'Passerelle défaillante',
    code: LucidErrorCodes.badGateway,
    severity: LucidErrorSeverity.error,
  );

  factory NetworkException.serviceUnavailable() => const NetworkException(
    'Service temporairement indisponible',
    code: LucidErrorCodes.serviceUnavailable,
    severity: LucidErrorSeverity.warning,
  );

  factory NetworkException.maintenanceMode() => const NetworkException(
    'Service en maintenance',
    code: LucidErrorCodes.maintenanceMode,
    severity: LucidErrorSeverity.info,
  );

  @override
  NetworkException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    int? statusCode,
    String? url,
  }) {
    return NetworkException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      statusCode: statusCode ?? this.statusCode,
      url: url ?? this.url,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'statusCode': statusCode, 'url': url});
    return map;
  }
}

class PaymentException extends LucidAbstractException {
  const PaymentException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.error,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.transactionId,
    this.amount,
    this.currency,
  });

  final String? transactionId;

  final double? amount;

  final String? currency;

  factory PaymentException.paymentFailed({String? transactionId}) => PaymentException(
    'Échec du paiement',
    code: LucidErrorCodes.paymentFailed,
    severity: LucidErrorSeverity.error,
    transactionId: transactionId,
  );

  factory PaymentException.insufficientFunds({double? amount, String? currency}) => PaymentException(
    'Fonds insuffisants${amount != null && currency != null ? ' pour $amount $currency' : ''}',
    code: LucidErrorCodes.insufficientFunds,
    severity: LucidErrorSeverity.warning,
    amount: amount,
    currency: currency,
  );

  factory PaymentException.cardDeclined() => const PaymentException(
    'Carte de crédit refusée',
    code: LucidErrorCodes.cardDeclined,
    severity: LucidErrorSeverity.warning,
  );

  factory PaymentException.transactionLimitExceeded({double? amount, String? currency}) => PaymentException(
    'Limite de transaction dépassée${amount != null && currency != null ? ' ($amount $currency)' : ''}',
    code: LucidErrorCodes.transactionLimitExceeded,
    severity: LucidErrorSeverity.warning,
    amount: amount,
    currency: currency,
  );

  factory PaymentException.invalidPaymentToken() => const PaymentException(
    'Jeton de paiement invalide',
    code: LucidErrorCodes.invalidPaymentToken,
    severity: LucidErrorSeverity.error,
  );

  @override
  PaymentException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? transactionId,
    double? amount,
    String? currency,
  }) {
    return PaymentException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'transactionId': transactionId, 'amount': amount, 'currency': currency});
    return map;
  }
}

class StorageException extends LucidAbstractException {
  const StorageException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.error,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.path,
    this.operation,
  });

  final String? path;

  final LucidStorageOperation? operation;

  factory StorageException.readError({String? path}) => StorageException(
    'Erreur lors de la lecture${path != null ? ' de $path' : ''}',
    code: LucidErrorCodes.readFailed,
    severity: LucidErrorSeverity.error,
    path: path,
    operation: LucidStorageOperation.read,
  );

  factory StorageException.writeError({String? path}) => StorageException(
    'Erreur lors de l\'écriture${path != null ? ' de $path' : ''}',
    code: LucidErrorCodes.writeFailed,
    severity: LucidErrorSeverity.error,
    path: path,
    operation: LucidStorageOperation.write,
  );

  factory StorageException.clearError({String? path}) => StorageException(
    'Erreur lors de l\'éffacement${path != null ? ' de $path' : ' complète'}',
    code: LucidErrorCodes.clearFailed,
    severity: LucidErrorSeverity.error,
    path: path,
    operation: LucidStorageOperation.clear,
  );

  factory StorageException.fileNotFound(String path) => StorageException(
    'Fichier non trouvé: $path',
    code: LucidErrorCodes.fileNotFound,
    severity: LucidErrorSeverity.warning,
    path: path,
    operation: LucidStorageOperation.read,
  );

  factory StorageException.diskFull() => const StorageException(
    'Espace disque insuffisant',
    code: LucidErrorCodes.diskFull,
    severity: LucidErrorSeverity.critical,
    operation: LucidStorageOperation.write,
  );

  factory StorageException.databaseLocked() => const StorageException(
    'Base de données verrouillée',
    code: LucidErrorCodes.databaseLocked,
    severity: LucidErrorSeverity.error,
    operation: LucidStorageOperation.write,
  );

  factory StorageException.quotaExceeded() => const StorageException(
    'Quota de stockage dépassé',
    code: LucidErrorCodes.quotaExceeded,
    severity: LucidErrorSeverity.error,
    operation: LucidStorageOperation.write,
  );

  @override
  StorageException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? path,
    LucidStorageOperation? operation,
  }) {
    return StorageException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      path: path ?? this.path,
      operation: operation ?? this.operation,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'path': path, 'operation': operation?.name});
    return map;
  }
}

class ValidationException extends LucidAbstractException {
  const ValidationException(
    super.message, {
    super.code,
    super.severity = LucidErrorSeverity.warning,
    super.context,
    super.timestamp,
    super.stackTrace,
    this.field,
    this.value,
  });

  final String? field;

  final dynamic value;

  factory ValidationException.required(String field) => ValidationException(
    'Le champ $field est requis',
    code: LucidErrorCodes.requiredField,
    field: field,
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.invalidFormat(String field, {dynamic value}) => ValidationException(
    'Format invalide pour le champ $field',
    code: LucidErrorCodes.invalidFormat,
    field: field,
    value: value,
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.invalidEmail(String email) => ValidationException(
    'Adresse email invalide: $email',
    code: LucidErrorCodes.invalidEmail,
    field: 'email',
    value: email,
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.weakPassword() => const ValidationException(
    'Le mot de passe ne respecte pas les critères de sécurité',
    code: LucidErrorCodes.weakPassword,
    field: 'password',
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.passwordMismatch() => const ValidationException(
    'Les mots de passe ne correspondent pas',
    code: LucidErrorCodes.passwordMismatch,
    field: 'password_confirmation',
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.outOfRange(String field, {dynamic value, dynamic min, dynamic max}) =>
      ValidationException(
        'Valeur hors limites pour $field${min != null && max != null ? ' (min: $min, max: $max)' : ''}',
        code: LucidErrorCodes.outOfRange,
        field: field,
        value: value,
        severity: LucidErrorSeverity.warning,
        context: {if (min != null) 'min': min, if (max != null) 'max': max},
      );

  factory ValidationException.invalidPhoneNumber(String phoneNumber) => ValidationException(
    'Numéro de téléphone invalide: $phoneNumber',
    code: LucidErrorCodes.invalidPhoneNumber,
    field: 'phone',
    value: phoneNumber,
    severity: LucidErrorSeverity.warning,
  );

  factory ValidationException.unsupportedFileType(String fileType) => ValidationException(
    'Type de fichier non supporté: $fileType',
    code: LucidErrorCodes.unsupportedFileType,
    field: 'file',
    value: fileType,
    severity: LucidErrorSeverity.warning,
  );

  @override
  ValidationException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? field,
    dynamic value,
  }) {
    return ValidationException(
      message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      field: field ?? this.field,
      value: value ?? this.value,
    );
  }

  @override
  LucidJsonMap toMap() {
    final map = super.toMap();
    map.addAll({'field': field, 'value': value?.toString()});
    return map;
  }
}
