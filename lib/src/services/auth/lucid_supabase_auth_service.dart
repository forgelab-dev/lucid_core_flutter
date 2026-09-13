import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/core.dart';
import '../../functions/functions.dart';

/// Implémentation Supabase (GoTrue) de [LucidAbstractAuthService].
///
/// Comme pour [LucidFirebaseAuthService][], la connexion sociale ne dépend
/// d'aucun SDK tiers: on injecte les jetons déjà obtenus (via
/// `google_sign_in`, `sign_in_with_apple`, ...) sous forme de
/// [LucidOAuthTokens] et on les échange via `signInWithIdToken`.
class LucidSupabaseAuthService implements LucidAbstractAuthService {
  LucidSupabaseAuthService({sb.SupabaseClient? client, this.googleTokensProvider, this.appleTokensProvider})
    : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  final Future<LucidOAuthTokens?> Function()? googleTokensProvider;
  final Future<LucidOAuthTokens?> Function()? appleTokensProvider;

  final _logger = LucidLogger();
  final _authStateController = StreamController<LucidAuthUser?>.broadcast();

  StreamSubscription<sb.AuthState>? _authStateSubscription;
  String? _cachedToken;

  sb.GoTrueClient get _auth => _client.auth;

  @override
  Future<void> initialize() async {
    await _authStateSubscription?.cancel();
    _authStateSubscription = _auth.onAuthStateChange.listen(_handleAuthStateChanged);
    await _handleAuthStateChanged(sb.AuthState(sb.AuthChangeEvent.initialSession, _auth.currentSession));
  }

  Future<void> _handleAuthStateChanged(sb.AuthState state) async {
    final session = state.session;
    if (session == null) {
      _cachedToken = null;
      _authStateController.add(null);
      return;
    }

    _cachedToken = session.accessToken;
    try {
      await LucidCacheHelper.manager.saveAuthToken(session.accessToken);
      if (session.refreshToken != null) {
        await LucidCacheHelper.manager.saveRefreshToken(session.refreshToken!);
      }
    } catch (e) {
      _logger.warn('Impossible de sauvegarder la session Supabase: $e', tag: 'AUTH');
    }

    _authStateController.add(_mapUser(session.user));
  }

  @override
  Stream<LucidAuthUser?> get authStateChanges => _authStateController.stream;

  @override
  LucidAuthUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  String? get currentToken => _cachedToken ?? _auth.currentSession?.accessToken;

  @override
  Future<LucidAuthResult> signIn(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(email: email, password: password);
      return _resultFromResponse(response);
    } on sb.AuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    } catch (e) {
      return LucidAuthResult.error('Connexion impossible: $e');
    }
  }

  @override
  Future<LucidAuthResult> signUp(LucidAuthCredentials credentials) async {
    try {
      final response = await _auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: {if (credentials.name != null) 'name': credentials.name, if (credentials.phoneNumber != null) 'phone_number': credentials.phoneNumber},
      );

      return _resultFromResponse(response);
    } on sb.AuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    } catch (e) {
      return LucidAuthResult.error('Inscription impossible: $e');
    }
  }

  @override
  Future<LucidAuthResult> signInWithGoogle() {
    return _signInWithIdToken(providerName: 'Google', provider: sb.OAuthProvider.google, tokensProvider: googleTokensProvider);
  }

  @override
  Future<LucidAuthResult> signInWithApple() {
    return _signInWithIdToken(providerName: 'Apple', provider: sb.OAuthProvider.apple, tokensProvider: appleTokensProvider);
  }

  Future<LucidAuthResult> _signInWithIdToken({
    required String providerName,
    required sb.OAuthProvider provider,
    required Future<LucidOAuthTokens?> Function()? tokensProvider,
  }) async {
    if (tokensProvider == null) {
      return LucidAuthResult.error(
        'Connexion $providerName non configurée: fournissez un callback à LucidSupabaseAuthService.',
      );
    }

    final tokens = await tokensProvider();
    if (tokens == null) return LucidAuthResult.error('Connexion $providerName annulée');
    if (tokens.idToken == null) return LucidAuthResult.error('Jeton d\'identité $providerName manquant');

    try {
      final response = await _auth.signInWithIdToken(
        provider: provider,
        idToken: tokens.idToken!,
        accessToken: tokens.accessToken,
        nonce: tokens.rawNonce,
      );

      return _resultFromResponse(response);
    } on sb.AuthException catch (e) {
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
      await _auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final email = _auth.currentUser?.email;
    if (email == null) throw AuthenticationException.unauthorized();

    try {
      await _auth.resend(type: sb.OtpType.signup, email: email);
    } on sb.AuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<LucidAuthResult> refreshToken() async {
    try {
      final response = await _auth.refreshSession();
      return _resultFromResponse(response);
    } on sb.AuthException catch (e) {
      return LucidAuthResult.error(_mapException(e).message);
    }
  }

  LucidAuthResult _resultFromResponse(sb.AuthResponse response) {
    final session = response.session;
    final user = response.user ?? session?.user;
    if (user == null) return LucidAuthResult.error('Utilisateur introuvable après authentification');

    _cachedToken = session?.accessToken ?? _cachedToken;

    return LucidAuthResult.success(user: _mapUser(user), token: session?.accessToken, refreshToken: session?.refreshToken);
  }

  LucidAuthUser _mapUser(sb.User user) {
    return LucidAuthUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      phoneNumber: user.phone,
      emailVerified: user.emailConfirmedAt != null,
      metadata: user.userMetadata ?? const {},
      createdAt: DateTime.tryParse(user.createdAt),
      lastSignIn: user.lastSignInAt != null ? DateTime.tryParse(user.lastSignInAt!) : null,
    );
  }

  AuthenticationException _mapException(sb.AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return AuthenticationException.invalidCredentials();
      case 'user_banned':
        return AuthenticationException.userSuspended();
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return AuthenticationException.accountLocked();
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return AuthenticationException.sessionExpired();
      default:
        return AuthenticationException(e.message, code: e.code);
    }
  }

  /// Libère les ressources internes (à appeler quand le service n'est plus utilisé).
  Future<void> dispose() async {
    await _authStateSubscription?.cancel();
    await _authStateController.close();
  }
}
