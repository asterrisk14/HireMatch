class AuthResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String token;
  final String role;
  final String phone;
  final bool isPremium;

  AuthResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.role,
    required this.phone,
    required this.isPremium,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'token': token,
      'role': role,
      'phone': phone,
      'isPremium': isPremium,
    };
  }
}
