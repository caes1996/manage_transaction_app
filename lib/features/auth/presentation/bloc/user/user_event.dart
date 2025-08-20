import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetUserByIdRequested extends UserEvent {
  final String id;
  GetUserByIdRequested(this.id);
  
  @override
  List<Object?> get props => [id];
}

class GetAllUsersRequested extends UserEvent {}

class CreateUserRequested extends UserEvent {
  final UserEntity user;
  final String password;
  
  CreateUserRequested(this.user, this.password);
  
  @override
  List<Object?> get props => [user, password];
}

class UsersWatchRequested extends UserEvent {}

class UsersStopWatching extends UserEvent {}

class UsersStreamEmitted extends UserEvent {
  final List<UserEntity> users;
  
  UsersStreamEmitted(this.users);
  
  @override
  List<Object?> get props => [users];
}