import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<void> updateUser(String id, UserEntity user);
  Future<void> deleteUser(String id);
  Future<UserEntity> getUserById(String id);
  Future<List<UserEntity>> getAllUsers();
}