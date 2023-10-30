// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyUser _$MyUserFromJson(Map<String, dynamic> json) => MyUser(
      uid: json['uid'] as String,
      notification_mode: json['notification_mode'] as String? ?? "none",
      eco_minder_id: json['eco_minder_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$MyUserToJson(MyUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'notification_mode': instance.notification_mode,
      'eco_minder_id': instance.eco_minder_id,
      'name': instance.name,
      'email': instance.email,
    };

EcoMinder _$EcoMinderFromJson(Map<String, dynamic> json) => EcoMinder(
      created_at:
          EcoMinder._dateTimeFromTimestamp(json['created_at'] as Timestamp),
      eco_minder_id: json['eco_minder_id'] as String,
      name: json['name'] as String,
      uid: json['uid'] as String,
      mode: json['mode'] as String? ?? "mild",
    );

Map<String, dynamic> _$EcoMinderToJson(EcoMinder instance) => <String, dynamic>{
      'created_at': EcoMinder._dateTimeAsIs(instance.created_at),
      'eco_minder_id': instance.eco_minder_id,
      'name': instance.name,
      'uid': instance.uid,
      'mode': instance.mode,
    };

StringSensorData _$StringSensorDataFromJson(Map<String, dynamic> json) =>
    StringSensorData(
      data: json['data'] as String,
      timestamp: StringSensorData._dateTimeFromTimestamp(
          json['timestamp'] as Timestamp),
    );

Map<String, dynamic> _$StringSensorDataToJson(StringSensorData instance) =>
    <String, dynamic>{
      'data': instance.data,
      'timestamp': StringSensorData._dateTimeAsIs(instance.timestamp),
    };

NumberSensorData _$NumberSensorDataFromJson(Map<String, dynamic> json) =>
    NumberSensorData(
      data: double.parse(json['data'] as String),
      timestamp: NumberSensorData._dateTimeFromTimestamp(
          json['timestamp'] as Timestamp),
    );

Map<String, dynamic> _$NumberSensorDataToJson(NumberSensorData instance) =>
    <String, dynamic>{
      'data': NumberSensorData._doubleAsIs(instance.data),
      'timestamp': NumberSensorData._dateTimeAsIs(instance.timestamp),
    };
