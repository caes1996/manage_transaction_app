// user_event.dart - Eventos completos
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Eventos existentes
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

// Nuevos eventos CRUD
class UpdateUserRequested extends UserEvent {
  final String userId;
  final UserEntity user;
  
  UpdateUserRequested(this.userId, this.user);
  
  @override
  List<Object?> get props => [userId, user];
}

class DeleteUserRequested extends UserEvent {
  final String userId;
  
  DeleteUserRequested(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

// Eventos para realtime
class UsersWatchRequested extends UserEvent {}

class UsersStopWatching extends UserEvent {}

class UsersStreamEmitted extends UserEvent {
  final List<UserEntity> users;
  
  UsersStreamEmitted(this.users);
  
  @override
  List<Object?> get props => [users];
}