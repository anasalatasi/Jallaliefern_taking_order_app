import 'dart:convert';

JwtToken jwtTokenFromJson(String str) {
  final jsonData = json.decode(str);
  return JwtToken.fromJson(jsonData);
}

class JwtToken {
  final String access;
  final String refresh;

  JwtToken({required this.access, required this.refresh});

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      JwtToken(access: json['access'], refresh: json['refresh']);
}
