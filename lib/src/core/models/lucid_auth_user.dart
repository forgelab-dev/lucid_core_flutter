import '../constants/constants.dart';

class LucidAuthUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final LucidJsonMap metadata;
  final LucidJsonMap customClaims;
  final DateTime? createdAt;
  final DateTime? lastSignIn;

  const LucidAuthUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.metadata = const {},
    this.customClaims = const {},
    this.createdAt,
    this.lastSignIn,
  });

  factory LucidAuthUser.fromJson(LucidJsonMap json) {
    return LucidAuthUser(
      id: (json['id'] ?? json['uid'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['displayName']).toString(),
      photoUrl: (json['photo_url'] ?? json['photoURL']).toString(),
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']).toString(),
      emailVerified: bool.parse("${json['email_verified'] ?? json['emailVerified'] ?? false}"),
      metadata: json['metadata'] as LucidJsonMap? ?? {},
      customClaims: json['custom_claims'] as LucidJsonMap? ?? json['customClaims'] as LucidJsonMap? ?? {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      lastSignIn: json['last_sign_in'] != null ? DateTime.parse(json['last_sign_in'] as String) : null,
    );
  }

  LucidJsonMap toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'email_verified': emailVerified,
      'metadata': metadata,
      'custom_claims': customClaims,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in': lastSignIn?.toIso8601String(),
    };
  }

  LucidAuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    LucidJsonMap? metadata,
    LucidJsonMap? customClaims,
    DateTime? createdAt,
    DateTime? lastSignIn,
  }) {
    return LucidAuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      metadata: metadata ?? this.metadata,
      customClaims: customClaims ?? this.customClaims,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }

  @override
  String toString() {
    return 'LucidAuthUser(id: $id, email: $email, name: $name, emailVerified: $emailVerified)';
  }
}
