import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../domain/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  UserBloc(this.userRepository) : super(UserLoading()) {
    on<GetUserByIdRequested>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getUserById(event.id);
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError('No se pudo obtener el usuario. Error: $e'));
      }
    });

    on<GetAllUsersRequested>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await userRepository.getAllUsers();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UserError('No se pudo obtener el usuario. Error: $e'));
      }
    });
  }
}
