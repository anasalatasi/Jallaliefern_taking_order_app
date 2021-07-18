import 'dart:convert';

class Order {
  final int id;
  final String slug;
  final String firstName;
  final String lastName;
  final int type;
  final String email;

  Order(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.slug,
      required this.type});

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      slug: json['slug'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      type: json['type'],
      email: json['email'],
    );
  }
  String getType() {
    if (this.type == 1)
      return "Delivery";
    else if (this.type == 2) return "Pickup";
    return "Unknown";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'first_name': firstName,
        'last_name': lastName,
        'type': type,
        'email': email,
      };
}
