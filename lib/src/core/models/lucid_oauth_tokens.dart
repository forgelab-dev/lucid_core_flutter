/// Jetons issus d'un flux OAuth natif (Google, Apple, ...) collectés côté
/// application avec le SDK de son choix (`google_sign_in`,
/// `sign_in_with_apple`, ...).
///
/// Ce contrat découple `lucid_core_flutter` de ces SDK: le plugin reste léger
/// pour les projets qui n'ont pas besoin de connexion sociale, tandis que ceux
/// qui en ont besoin fournissent ces jetons via un callback à
/// [LucidFirebaseAuthService] ou [LucidSupabaseAuthService].
class LucidOAuthTokens {
  const LucidOAuthTokens({this.idToken, this.accessToken, this.rawNonce});

  final String? idToken;
  final String? accessToken;

  /// Nonce brut utilisé pour la connexion Apple (protection anti-rejeu).
  final String? rawNonce;
}
