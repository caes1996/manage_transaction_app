import 'package:equatable/equatable.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}
class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  SignUpRequested(this.email, this.password, this.name, this.role);
}

class SignOutRequested extends AuthEvent {}