import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetUserByIdRequested extends UserEvent {
  final String id;
  GetUserByIdRequested(this.id);
}

class GetAllUsersRequested extends UserEvent {}
