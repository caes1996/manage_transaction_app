import 'package:manage_transaction_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final UserRemoteDataSource userRemote;
  AuthRepositoryImpl(this.userRemote, this.remote);

  @override
  Future<UserEntity> signIn(String email, String password) => remote.signIn(email, password);

  @override
  Future<UserEntity> signUp(String email, String password, String name, UserRole role) => remote.signUp(email, password, name, role);

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Session? currentSession() => remote.currentSession();

  @override
  Stream<UserEntity?> getAuthStateChanges() => remote.getAuthStateChanges();

  @override
  UserEntity? currentUser() => remote.currentUser();

  @override
  Future<void> ensureCurrentUserRow() async {
    final authUser = remote.client.auth.currentUser;
    if (authUser == null) return;
    try {
      await userRemote.ensureSelfExists(authUser);
    } catch (e) {
      // ignore: avoid_print
      print('Error al iniciar sesión: auth_repository_impl line 36: $e');
    }
  }

  @override
  Future<bool> existsUserRoot() => userRemote.existsUserRoot();
}