import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';


class AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSource(this.client);

  Future<UserEntity> signIn(String email, String password) async {
    final result = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (result.user == null) throw Exception('Credentiales inválidas');
    return UserModel.fromSupabaseUser(result.user!);
  }

  Future<UserEntity> signUp(String email, String password) async {
    final result = await client.auth.signUp(
      email: email,
      password: password,
    );
    if (result.user == null) throw Exception('No se pudo crear el usuario');
    // await client.schema('mock_data').from('users').insert({
    //   'id': result.user!.id,
    //   'email': result.user!.email,
    //   'name': 'User test', // TODO: nombre real
    //   'role': 'transactional',
    //   'created_at': DateTime.now(),
    // });
    print('result.user! -> ${result.user!}');
    return UserModel.fromSupabaseUser(result.user!);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Stream<UserEntity?> getAuthStateChanges() {
    return client.auth.onAuthStateChange.map((event) {
      if (event.session == null) return null;
      return UserModel.fromSupabaseUser(event.session!.user);
    });
  }

  UserEntity? currentUser() {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }
}