import 'package:equatable/equatable.dart';

enum UserRole { root, admin, transactional }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, role, createdAt];
}