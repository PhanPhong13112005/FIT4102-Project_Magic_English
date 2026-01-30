class AuthResponse {
  final bool success;
  final String message;
  final AuthResponseData? data;

  AuthResponse({required this.success, required this.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AuthResponseData.fromJson(json['data'])
          : null,
    );
  }
}

class AuthResponseData {
  final int userId;
  final String email;
  final String username;
  final String fullName;
  final String token;
  final DateTime tokenExpiration;

  AuthResponseData({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.token,
    required this.tokenExpiration,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      token: json['token'] ?? '',
      tokenExpiration: DateTime.parse(
        json['tokenExpiration'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
