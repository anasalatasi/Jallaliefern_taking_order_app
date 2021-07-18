import 'dart:convert';

class JwtToken {
  final String access;
  final String refresh;

  JwtToken({required this.access, required this.refresh});

  factory JwtToken.fromRawJson(String str) => JwtToken.fromJson(json.decode(str));

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      JwtToken(access: json['access'], refresh: json['refresh']);
}
