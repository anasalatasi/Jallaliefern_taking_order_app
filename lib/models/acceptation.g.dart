// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Acceptation _$AcceptationFromJson(Map<String, dynamic> json) {
  return Acceptation(
    accepted: json['accepted'] as bool,
    eta: json['eta'] as String?,
  );
}

Map<String, dynamic> _$AcceptationToJson(Acceptation instance) =>
    <String, dynamic>{
      'accepted': instance.accepted,
      'eta': instance.eta,
    };
