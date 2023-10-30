import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class MyUser {
  final String uid;
  final String notification_mode;
  final String? eco_minder_id;
  final String? name;
  final String? email;

  MyUser({
    required this.uid,
    this.notification_mode = "none",
    this.eco_minder_id,
    this.name,
    this.email,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) => _$MyUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyUserToJson(this);
}

@JsonSerializable()
class EcoMinder {
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeAsIs)
  final DateTime created_at;
  final String eco_minder_id;
  final String name;
  final String uid;
  final String mode;

  EcoMinder({
    required this.created_at,
    required this.eco_minder_id,
    required this.name,
    required this.uid,
    this.mode = "mild",
  });

  factory EcoMinder.fromJson(Map<String, dynamic> json) =>
      _$EcoMinderFromJson(json);

  Map<String, dynamic> toJson() => _$EcoMinderToJson(this);

  static FieldValue _dateTimeAsIs(DateTime dateTime) =>
      FieldValue.serverTimestamp();

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) {
    return DateTime.parse(timestamp.toDate().toString());
  }
}

class UserNEcoMinder {
  final MyUser user;
  final EcoMinder? ecoMinder;

  UserNEcoMinder({
    required this.user,
    required this.ecoMinder,
  });
}

enum EcoMinderMode { mild, alert }

enum NotificationMode { none, medium, high }

@JsonSerializable()
class StringSensorData {
  final String data;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeAsIs)
  final DateTime timestamp;

  StringSensorData({
    required this.data,
    required this.timestamp,
  });

  factory StringSensorData.fromJson(Map<String, dynamic> json) =>
      _$StringSensorDataFromJson(json);
  Map<String, dynamic> toJson() => _$StringSensorDataToJson(this);

  static DateTime _dateTimeAsIs(DateTime dateTime) => dateTime;

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) {
    return DateTime.parse(timestamp.toDate().toString());
  }
}

@JsonSerializable()
class NumberSensorData {
  @JsonKey(fromJson: double.parse, toJson: _doubleAsIs)
  final double data;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeAsIs)
  final DateTime timestamp;

  NumberSensorData({
    required this.data,
    required this.timestamp,
  });

  factory NumberSensorData.fromJson(Map<String, dynamic> json) =>
      _$NumberSensorDataFromJson(json);
  Map<String, dynamic> toJson() => _$NumberSensorDataToJson(this);

  static DateTime _dateTimeAsIs(DateTime dateTime) => dateTime;
  static double _doubleAsIs(double dateTime) => dateTime;

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) {
    return DateTime.parse(timestamp.toDate().toString());
  }
}

class SensorDatas {
  final NumberSensorData lightLevel;
  final NumberSensorData indoorTemp;
  final NumberSensorData outdoorTemp;
  final NumberSensorData airQuality;

  SensorDatas({
    required this.lightLevel,
    required this.indoorTemp,
    required this.outdoorTemp,
    required this.airQuality,
  });

  static SensorDatas GetDefault() {
    return SensorDatas(
      lightLevel: NumberSensorData(data: -1, timestamp: DateTime.now()),
      indoorTemp: NumberSensorData(data: -1, timestamp: DateTime.now()),
      outdoorTemp: NumberSensorData(data: -1, timestamp: DateTime.now()),
      airQuality: NumberSensorData(data: -1, timestamp: DateTime.now()),
    );
  }
}
