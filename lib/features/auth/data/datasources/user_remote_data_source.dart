import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manage_transaction_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDataSource {
  final SupabaseClient client;
  UserRemoteDataSource(this.client);

  final String _schema = dotenv.env['DB_SCHEMA_TEST']!;
  final String _tableName = 'users';

  PostgrestQueryBuilder get _usersTable => client.schema(_schema).from(_tableName);

  Future<bool> existsUserRoot() async {
    final exists = await _usersTable.select().eq('role', 'root').limit(1).maybeSingle();
    return exists != null;
  }

  Future<void> ensureSelfExists(User user) async {
    final exists = await _usersTable.select().eq('id', user.id).maybeSingle();
    if (exists == null) {
      await _usersTable.insert({
        'id': user.id,
        'email': user.email,
        'name': (user.userMetadata?['name'] ?? ''),
        'role': (user.userMetadata?['role'] ?? ''),
      });
    }
  }

  Future<void> updateUser(String id, UserModel user) async {
    await _usersTable.update(user.toDbUpdate()).eq('id', id).select().single();
  }

  Future<void> deleteUser(String id) async {
    await _usersTable.delete().eq('id', id).select().single();
  }

  Future<UserModel> getUserById(String id) async {
    final row = await _usersTable.select().eq('id', id).maybeSingle();
    if (row == null) throw Exception('No se encontro el usuario');
    return UserModel.fromDb(row);
  }

  Future<List<UserModel>> getAllUsers() async {
    final rows = await _usersTable.select();
    return rows.map((row) => UserModel.fromDb(row)).toList();
  }
}