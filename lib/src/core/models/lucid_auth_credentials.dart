class LucidAuthCredentials {
  final String email;
  final String password;
  final String? name;
  final String? phoneNumber;

  const LucidAuthCredentials({required this.email, required this.password, this.name, this.phoneNumber});
}
