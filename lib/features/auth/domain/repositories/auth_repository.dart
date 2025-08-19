import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password, String name, UserRole role);
  Future<void> signOut();
  Session? currentSession();
  Stream<UserEntity?> getAuthStateChanges();
  UserEntity? currentUser();

  Future<void> ensureCurrentUserRow();
  Future<bool> existsUserRoot();
  Future<UserEntity?> getCurrentUserFromBd();
}