import 'package:equatable/equatable.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

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

class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}