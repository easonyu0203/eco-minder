import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

// Enumeration to make sure the endpoint is one of the given three options
enum Endpoint {
  @JsonValue('verify_device')
  verifyDevice,
  @JsonValue('set_connect_wifi')
  setConnectWiFi,
}

enum Setter {
  @JsonValue("EcoMinder")
  ecoMinder,
  @JsonValue("App")
  app,
}

@JsonSerializable()
class Request {
  final Endpoint endpoint;
  final Payload payload;
  final Setter setter;

  Request(
      {required this.endpoint, required this.payload, required this.setter});

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}

@JsonSerializable()
class Response {
  final Endpoint endpoint;
  final Payload payload;
  final Setter setter;

  Response(
      {required this.endpoint, required this.payload, required this.setter});

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class Payload {
  final String? device_type;
  final String? status;
  final List<WiFi>? wifi_list;
  final String? SSID;
  final String? password;
  final String? id;

  Payload({
    this.device_type,
    this.status,
    this.wifi_list,
    this.SSID,
    this.password,
    this.id,
  });

  factory Payload.fromJson(Map<String, dynamic> json) =>
      _$PayloadFromJson(json);
  Map<String, dynamic> toJson() => _$PayloadToJson(this);
}

@JsonSerializable()
class WiFi {
  final String SSID;
  final String security_protocol;

  WiFi({required this.SSID, required this.security_protocol});

  factory WiFi.fromJson(Map<String, dynamic> json) => _$WiFiFromJson(json);
  Map<String, dynamic> toJson() => _$WiFiToJson(this);
}

@JsonSerializable()
class Credentials {
  final WpaCredentials? wpa;
  final WepCredentials? wep;
  final OpenCredentials? open;

  Credentials({this.wpa, this.wep, this.open});

  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialsToJson(this);
}

@JsonSerializable()
class WpaCredentials {
  final String password;

  WpaCredentials({required this.password});

  factory WpaCredentials.fromJson(Map<String, dynamic> json) =>
      _$WpaCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$WpaCredentialsToJson(this);
}

@JsonSerializable()
class WepCredentials {
  final String passphrase;

  WepCredentials({required this.passphrase});

  factory WepCredentials.fromJson(Map<String, dynamic> json) =>
      _$WepCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$WepCredentialsToJson(this);
}

@JsonSerializable()
class OpenCredentials {
  // You might want to add fields specific to open networks if needed
  // For now, it's empty

  OpenCredentials();

  factory OpenCredentials.fromJson(Map<String, dynamic> json) =>
      _$OpenCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$OpenCredentialsToJson(this);
}
