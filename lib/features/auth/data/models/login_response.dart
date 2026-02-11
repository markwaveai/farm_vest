import 'dart:convert';

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final List<String> roles;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.roles,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    List<String> rolesList = [];
    if (map['roles'] != null) {
      rolesList = List<String>.from(map['roles']);
    } else if (map['user'] != null && map['user']['roles'] != null) {
      rolesList = List<String>.from(map['user']['roles']);
    }

    return LoginResponse(
      accessToken: map['access_token'] ?? '',
      tokenType: map['token_type'] ?? '',
      roles: rolesList,
    );
  }

  factory LoginResponse.fromJson(String source) =>
      LoginResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'roles': roles,
    };
  }

  String toJson() => json.encode(toMap());
}
