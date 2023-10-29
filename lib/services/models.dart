import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class MyUser {
  final String uid;
  final String? eco_minder_id;
  final String? name;
  final String? email;

  MyUser({
    required this.uid,
    this.eco_minder_id,
    this.name,
    this.email,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) => _$MyUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyUserToJson(this);
}
