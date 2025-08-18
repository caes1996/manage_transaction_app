import 'package:manage_transaction_app/features/auth/data/models/user_model.dart';

import '../datasources/user_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  UserRepositoryImpl(this.remote);

  

  @override
  Future<void> updateUser(String id, UserEntity user) {
    final model = UserModel.fromEntity(user);
    return remote.updateUser(id, model);
  }

  @override
  Future<void> deleteUser(String id) => remote.deleteUser(id);

  @override
  Future<UserEntity> getUserById(String id) => remote.getUserById(id);

  @override
  Future<List<UserEntity>> getAllUsers() => remote.getAllUsers();
}