// user_bloc.dart - Versión mejorada
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/entities/user_entity.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  StreamSubscription<List<UserEntity>>? _usersSub;

  UserBloc(this.userRepository, this.authRepository) : super(UserInitial()) {
    
    // Obtener usuario por ID
    on<GetUserByIdRequested>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getUserById(event.id);
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError('No se pudo obtener el usuario. Error: $e'));
      }
    });

    // Carga manual completa (fallback)
    on<GetAllUsersRequested>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await userRepository.getAllUsers();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UserError('No se pudieron obtener los usuarios. Error: $e'));
      }
    });

    // Crear usuario con mejor manejo de estados
    on<CreateUserRequested>((event, emit) async {
      emit(UserOperationLoading('creating'));
      try {
        final createdAuthUser = await authRepository.signUp(
          event.user.email,
          event.password,
          event.user.name,
          event.user.role,
        );
        
        await userRepository.createUser(createdAuthUser);
        emit(UserCreated('Usuario creado correctamente'));
        
      } catch (e) {
        emit(UserError('No se pudo crear el usuario. Error: $e'));
      }
    });

    // Realtime: iniciar observación
    on<UsersWatchRequested>((event, emit) async {
      if (_usersSub != null) return; // Ya está observando
      
      emit(UserLoading());
      
      _usersSub = userRepository.watchUsers().listen(
        (users) => add(UsersStreamEmitted(users)),
        onError: (e) {
          emit(UserError('Error en tiempo real: $e'));
        },
      );
    });

    // Datos del stream recibidos
    on<UsersStreamEmitted>((event, emit) {
      emit(UsersLoaded(event.users));
    });

    // Detener observación
    on<UsersStopWatching>((event, emit) async {
      await _usersSub?.cancel();
      _usersSub = null;
    });
  }

  @override
  Future<void> close() async {
    await _usersSub?.cancel();
    return super.close();
  }
}