import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(id: id, name: name, email: email, username: username);

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
    username: user.username,
  );
}
