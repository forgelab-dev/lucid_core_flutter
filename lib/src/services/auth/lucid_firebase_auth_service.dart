import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/core.dart';
import '../../functions/functions.dart';

/// Implémentation Firebase Auth de [LucidAbstractAuthService].
///
/// La connexion sociale (Google/Apple) ne dépend d'aucun SDK tiers ici: on
/// injecte les jetons déjà obtenus (via `google_sign_in`,
/// `sign_in_with_apple`, ...) sous forme de [LucidOAuthTokens], pour que
/// `lucid_core_flutter` reste léger pour les projets qui n'ont pas besoin de
/// connexion sociale.
class LucidFirebaseAuthService implements LucidAbstractAuthService {
  LucidFirebaseAuthService({fb.FirebaseAuth? auth, this.googleTokensProvider, this.appleTokensProvider})
    : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  final Future<LucidOAuthTokens?> Function()? googleTokensProvider;
  final Future<LucidOAuthTokens?> Function()? appleTokensProvider;

  final _logger = LucidLogger();
  final _authStateController = StreamController<LucidAuthUser?>.broadcast();

  StreamSubscription<fb.User?>? _authStateSubscription;
  String? _cachedToken;

  @override
  Future<void> initialize() async {
    await _authStateSubscription?.cancel();
    _authStateSubscription = _auth.authStateChanges().listen(_handleAuthStateChanged);
    await _handleAuthStateChanged(_auth.currentUser);
  }

  Future<void> _handleAuthStateChanged(fb.User? user) async {
    if (user == null) {
      _cachedToken = null;
      _authStateController.add(null);
      return;
    }

    try {
      _cachedToken = await user.getIdToken();
      if (_cachedToken != null) {
        await LucidCacheHelper.manager.saveAuthToken(_cachedToken!);
      }
    } catch (e) {
      _logger.warn('Impossible de récupérer le token Firebase: $e', tag: 'AUTH');
    }

    _authStateController.add(_mapUser(user));
  }

  @override
  Stream<LucidAuthUser?> get authStateChanges => _authStateController.stream;

  @override
  LucidAuthUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  String? get currentToken => _cachedToken;

  @override
  Future<LucidAuthResult> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await _resultFromCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    } catch (e) {
      return LucidAuthResult.error('Connexion impossible: $e');
    }
  }

  @override
  Future<LucidAuthResult> signUp(LucidAuthCredentials credentials) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (credentials.name != null && credentials.name!.isNotEmpty) {
        await credential.user?.updateDisplayName(credentials.name);
        await credential.user?.reload();
      }

      return await _resultFromCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    } catch (e) {
      return LucidAuthResult.error('Inscription impossible: $e');
    }
  }

  @override
  Future<LucidAuthResult> signInWithGoogle() {
    return _signInWithOAuth(
      providerName: 'Google',
      tokensProvider: googleTokensProvider,
      buildCredential: (tokens) => fb.GoogleAuthProvider.credential(idToken: tokens.idToken, accessToken: tokens.accessToken),
    );
  }

  @override
  Future<LucidAuthResult> signInWithApple() {
    return _signInWithOAuth(
      providerName: 'Apple',
      tokensProvider: appleTokensProvider,
      buildCredential: (tokens) => fb.OAuthProvider('apple.com').credential(idToken: tokens.idToken, rawNonce: tokens.rawNonce),
    );
  }

  Future<LucidAuthResult> _signInWithOAuth({
    required String providerName,
    required Future<LucidOAuthTokens?> Function()? tokensProvider,
    required fb.OAuthCredential Function(LucidOAuthTokens tokens) buildCredential,
  }) async {
    if (tokensProvider == null) {
      return LucidAuthResult.error(
        'Connexion $providerName non configurée: fournissez un callback à LucidFirebaseAuthService.',
      );
    }

    try {
      final tokens = await tokensProvider();
      if (tokens == null) return LucidAuthResult.error('Connexion $providerName annulée');

      final credential = await _auth.signInWithCredential(buildCredential(tokens));
      return await _resultFromCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    } catch (e) {
      return LucidAuthResult.error('Connexion $providerName impossible: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _cachedToken = null;
    await LucidCacheHelper.manager.clearAuthTokens();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthenticationException.unauthorized();

    try {
      await user.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<LucidAuthResult> refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return LucidAuthResult.error('Aucun utilisateur connecté');

    try {
      final token = await user.getIdToken(true);
      _cachedToken = token;
      if (token != null) await LucidCacheHelper.manager.saveAuthToken(token);

      return LucidAuthResult.success(user: _mapUser(user), token: token);
    } on fb.FirebaseAuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    }
  }

  Future<LucidAuthResult> _resultFromCredential(fb.UserCredential credential) async {
    final user = credential.user;
    if (user == null) return LucidAuthResult.error('Utilisateur introuvable après authentification');

    final token = await user.getIdToken();
    _cachedToken = token;
    if (token != null) await LucidCacheHelper.manager.saveAuthToken(token);

    return LucidAuthResult.success(user: _mapUser(user), token: token);
  }

  LucidAuthUser _mapUser(fb.User user) {
    return LucidAuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastSignIn: user.metadata.lastSignInTime,
    );
  }

  AuthenticationException _mapException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return AuthenticationException.invalidCredentials();
      case 'user-disabled':
        return AuthenticationException.userSuspended();
      case 'too-many-requests':
        return AuthenticationException.accountLocked();
      case 'requires-recent-login':
        return AuthenticationException.sessionExpired();
      case 'operation-not-allowed':
        return AuthenticationException.permissionDenied();
      default:
        return AuthenticationException(e.message ?? 'Erreur d\'authentification Firebase', code: e.code);
    }
  }

  /// Libère les ressources internes (à appeler quand le service n'est plus utilisé).
  Future<void> dispose() async {
    await _authStateSubscription?.cancel();
    await _authStateController.close();
  }
}
