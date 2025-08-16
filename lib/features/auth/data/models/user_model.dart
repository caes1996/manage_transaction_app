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

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] ?? '',
      role: _mapRole(metadata['role']),
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: _mapRole(map['role']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt,
    };
  }

  static UserRole _mapRole(dynamic role) {
    if (role == null) return UserRole.transactional;
    if (role is String) return UserRole.values.firstWhere((e) => e.name == role);
    throw Exception('Role inválido');
  }
}