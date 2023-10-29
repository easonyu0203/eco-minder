// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyUser _$MyUserFromJson(Map<String, dynamic> json) => MyUser(
      uid: json['uid'] as String,
      eco_minder_id: json['eco_minder_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$MyUserToJson(MyUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'eco_minder_id': instance.eco_minder_id,
      'name': instance.name,
      'email': instance.email,
    };
