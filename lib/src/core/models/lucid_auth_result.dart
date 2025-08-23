import 'lucid_auth_user.dart';

class LucidAuthResult {
  final bool success;
  final LucidAuthUser? user;
  final String? token;
  final String? refreshToken;
  final String? error;
  final bool requiresTwoFactor;
  final bool requiresVerification;

  const LucidAuthResult({
    required this.success,
    this.user,
    this.token,
    this.refreshToken,
    this.error,
    this.requiresTwoFactor = false,
    this.requiresVerification = false,
  });

  factory LucidAuthResult.success({required LucidAuthUser user, String? token, String? refreshToken}) {
    return LucidAuthResult(success: true, user: user, token: token, refreshToken: refreshToken);
  }

  factory LucidAuthResult.error(String error) {
    return LucidAuthResult(success: false, error: error);
  }

  factory LucidAuthResult.requiresTwoFactor() {
    return const LucidAuthResult(success: false, requiresTwoFactor: true);
  }

  factory LucidAuthResult.requiresVerification() {
    return const LucidAuthResult(success: false, requiresVerification: true);
  }
}
