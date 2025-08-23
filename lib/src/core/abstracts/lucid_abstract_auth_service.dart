import '../models/models.dart';

abstract class LucidAbstractAuthService {
  Future<void> initialize();

  Future<LucidAuthResult> signIn(String email, String password);

  Future<LucidAuthResult> signUp(LucidAuthCredentials credentials);

  Future<LucidAuthResult> signInWithGoogle();

  Future<LucidAuthResult> signInWithApple();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<LucidAuthResult> refreshToken();

  Stream<LucidAuthUser?> get authStateChanges;

  LucidAuthUser? get currentUser;

  String? get currentToken;
}
