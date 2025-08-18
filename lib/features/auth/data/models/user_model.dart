import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.createdAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static UserRole _parseRole(dynamic v) {
    final s = (v ?? '').toString();
    switch (s) {
      case 'root': return UserRole.root;
      case 'admin': return UserRole.admin;
      case 'transactional': return UserRole.transactional;
      default: return UserRole.transactional;
    }
  }

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] ?? '',
      role: _parseRole(metadata['role']),
      createdAt: _parseDate(user.createdAt)!,
    );
  }

  factory UserModel.fromDb(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: _parseRole(map['role']),
      createdAt: _parseDate(map['created_at'])!,
    );
  }

  Map<String, dynamic> toDbInsert() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.name,
  }..removeWhere((k, v) => v == null);

  Map<String, dynamic> toDbUpdate() => {
    'name': name,
  }..removeWhere((k, v) => v == null);

  factory UserModel.fromEntity(UserEntity e) => UserModel(
    id: e.id,
    email: e.email,
    name: e.name,
    role: e.role,
    createdAt: e.createdAt,
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    role: role,
    createdAt: createdAt,
  );
}
