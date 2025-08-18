import '../datasources/user_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  UserRepositoryImpl(this.remote);

  @override
  Future<UserEntity> getUserById(String id) => remote.getUserById(id);

  @override
  Future<List<UserEntity>> getAllUsers() => remote.getAllUsers();
}