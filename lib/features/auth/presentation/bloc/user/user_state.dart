// user_state.dart - Estados mejorados
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserEntity user;
  UserLoaded(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UsersLoaded extends UserState {
  final List<UserEntity> users;
  UsersLoaded(this.users);
  
  @override
  List<Object?> get props => [users];
}

// Estados para operaciones CRUD con mejor control
class UserCreated extends UserState {
  final String message;
  final bool shouldCloseModal;
  
  UserCreated(this.message, {this.shouldCloseModal = true});
  
  @override
  List<Object?> get props => [message, shouldCloseModal];
}

class UserUpdated extends UserState {
  final String message;
  final bool shouldCloseModal;
  
  UserUpdated(this.message, {this.shouldCloseModal = true});
  
  @override
  List<Object?> get props => [message, shouldCloseModal];
}

class UserDeleted extends UserState {
  final String message;
  
  UserDeleted(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UserOperationLoading extends UserState {
  final String operation; // 'creating', 'updating', 'deleting'
  
  UserOperationLoading(this.operation);
  
  @override
  List<Object?> get props => [operation];
}