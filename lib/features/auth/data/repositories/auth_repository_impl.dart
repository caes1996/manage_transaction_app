import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity> signIn(String email, String password) => remote.signIn(email, password);

  @override
  Future<UserEntity> signUp(String email, String password) => remote.signUp(email, password);

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Session? currentSession() => remote.currentSession();

  @override
  Stream<UserEntity?> getAuthStateChanges() => remote.getAuthStateChanges();

  @override
  UserEntity? currentUser() => remote.currentUser();
}