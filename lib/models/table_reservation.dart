import 'dart:convert';

class TableReservation {
  int id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String datetime;
  String createdAt;
  int status;
  int personsCount;
  TableReservation({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.datetime,
    required this.status,
    required this.personsCount,
    required this.createdAt,
  });

  TableReservation copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? datetime,
    int? status,
    int? personsCount,
    String? createdAt,
  }) {
    return TableReservation(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        datetime: datetime ?? this.datetime,
        status: status ?? this.status,
        personsCount: personsCount ?? this.personsCount,
        createdAt: createdAt ?? this.createdAt);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'datetime': datetime,
      'status': status,
      'persons_count': personsCount,
      'created_at': createdAt
    };
  }

  factory TableReservation.fromMap(Map<String, dynamic> map) {
    return TableReservation(
        id: map['id'],
        firstName: map['first_name'] != null ? map['first_name'] : null,
        lastName: map['last_name'] != null ? map['last_name'] : null,
        email: map['email'] != null ? map['email'] : null,
        phone: map['phone'] != null ? map['phone'] : null,
        datetime: map['datetime'],
        status: map['status'],
        personsCount: map['persons_count'],
        createdAt: map['created_at']);
  }

  String toJson() => json.encode(toMap());

  factory TableReservation.fromJson(String source) =>
      TableReservation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TableReservation(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, datetime: $datetime, status: $status, personsCount: $personsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TableReservation &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.phone == phone &&
        other.datetime == datetime &&
        other.status == status &&
        other.personsCount == personsCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        datetime.hashCode ^
        status.hashCode ^
        personsCount.hashCode;
  }
}
