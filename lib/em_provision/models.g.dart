// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      endpoint: $enumDecode(_$EndpointEnumMap, json['endpoint']),
      payload: Payload.fromJson(json['payload'] as Map<String, dynamic>),
      setter: $enumDecode(_$SetterEnumMap, json['setter']),
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'endpoint': _$EndpointEnumMap[instance.endpoint]!,
      'payload': instance.payload,
      'setter': _$SetterEnumMap[instance.setter]!,
    };

const _$EndpointEnumMap = {
  Endpoint.verifyDevice: 'verify_device',
  Endpoint.setConnectWiFi: 'set_connect_wifi',
};

const _$SetterEnumMap = {
  Setter.ecoMinder: 'EcoMinder',
  Setter.app: 'App',
};

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      endpoint: $enumDecode(_$EndpointEnumMap, json['endpoint']),
      payload: Payload.fromJson(json['payload'] as Map<String, dynamic>),
      setter: $enumDecode(_$SetterEnumMap, json['setter']),
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'endpoint': _$EndpointEnumMap[instance.endpoint]!,
      'payload': instance.payload,
      'setter': _$SetterEnumMap[instance.setter]!,
    };

Payload _$PayloadFromJson(Map<String, dynamic> json) => Payload(
      device_type: json['device_type'] as String?,
      status: json['status'] as String?,
      wifi_list: (json['wifi_list'] as List<dynamic>?)
          ?.map((e) => WiFi.fromJson(e as Map<String, dynamic>))
          .toList(),
      SSID: json['SSID'] as String?,
      password: json['password'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'device_type': instance.device_type,
      'status': instance.status,
      'wifi_list': instance.wifi_list,
      'SSID': instance.SSID,
      'password': instance.password,
      'id': instance.id,
    };

WiFi _$WiFiFromJson(Map<String, dynamic> json) => WiFi(
      SSID: json['SSID'] as String,
      security_protocol: json['security_protocol'] as String,
    );

Map<String, dynamic> _$WiFiToJson(WiFi instance) => <String, dynamic>{
      'SSID': instance.SSID,
      'security_protocol': instance.security_protocol,
    };

Credentials _$CredentialsFromJson(Map<String, dynamic> json) => Credentials(
      wpa: json['wpa'] == null
          ? null
          : WpaCredentials.fromJson(json['wpa'] as Map<String, dynamic>),
      wep: json['wep'] == null
          ? null
          : WepCredentials.fromJson(json['wep'] as Map<String, dynamic>),
      open: json['open'] == null
          ? null
          : OpenCredentials.fromJson(json['open'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CredentialsToJson(Credentials instance) =>
    <String, dynamic>{
      'wpa': instance.wpa,
      'wep': instance.wep,
      'open': instance.open,
    };

WpaCredentials _$WpaCredentialsFromJson(Map<String, dynamic> json) =>
    WpaCredentials(
      password: json['password'] as String,
    );

Map<String, dynamic> _$WpaCredentialsToJson(WpaCredentials instance) =>
    <String, dynamic>{
      'password': instance.password,
    };

WepCredentials _$WepCredentialsFromJson(Map<String, dynamic> json) =>
    WepCredentials(
      passphrase: json['passphrase'] as String,
    );

Map<String, dynamic> _$WepCredentialsToJson(WepCredentials instance) =>
    <String, dynamic>{
      'passphrase': instance.passphrase,
    };

OpenCredentials _$OpenCredentialsFromJson(Map<String, dynamic> json) =>
    OpenCredentials();

Map<String, dynamic> _$OpenCredentialsToJson(OpenCredentials instance) =>
    <String, dynamic>{};
