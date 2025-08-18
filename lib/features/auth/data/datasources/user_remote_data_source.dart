import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDataSource {
  final SupabaseClient client;
  UserRemoteDataSource(this.client);
  final String schema = dotenv.env['DB_SCHEMA_TEST']!;
  SupabaseQueryBuilder get _usersTable => client.from('v_users');

  UserEntity _rowToEntity(Map<String, dynamic> row) {
    return UserEntity(
      id: row['id'] as String,
      email: row['email'] as String,
      name: row['name'] as String,
      role: UserRole.values.firstWhere((e) => e.name == row['role']),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Future<UserEntity> getUserById(String id) async {
    final result = await _usersTable.select().eq('id', id).maybeSingle();
    if (result == null) throw Exception('Usuario no encontrado');
    return _rowToEntity(result);
  }

  Future<List<UserEntity>> getAllUsers() async {
    final result = await _usersTable.select();
    final users = result.map((row) {
      return _rowToEntity(row);
    }
    ).toList();
    return users;
  }
}