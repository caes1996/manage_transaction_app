import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/auth/data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _subscription;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthStarted>((event, emit) async {
      try {
        final session = authRepository.currentSession();

        if (session != null) {
          try {
            await authRepository.ensureCurrentUserRow();
            final userFromDB = await authRepository.getCurrentUserFromBd();
            if (userFromDB != null) {
              emit(AuthAuthenticated(userFromDB));
            } else {
              // Fallback si no se puede obtener desde DB
              emit(AuthAuthenticated(UserModel.fromSupabaseUser(session.user)));
            }
          } catch (e) {
            // ignore: avoid_print
            print('Error al iniciar sesión: auth_bloc line 19: $e');
            emit(AuthAuthenticated(UserModel.fromSupabaseUser(session.user)));
          }
        } else {
          emit(AuthUnauthenticated());
        }

        _subscription?.cancel();
        _subscription = authRepository.getAuthStateChanges().listen((user) async {
          if (user != null) {
            try {
              await authRepository.ensureCurrentUserRow();
              
              // Obtener usuario completo desde DB después del cambio de estado
              final userFromDB = await authRepository.getCurrentUserFromBd();
              if (userFromDB != null) {
                add(_AuthSessionArrived(user: userFromDB));
              } else {
                add(_AuthSessionArrived(user: user));
              }
            } catch (e) {
              // ignore: avoid_print
              print('Error al iniciar sesión: auth_bloc line 32: $e');
              add(_AuthSessionArrived(user: user));
            }
          } else {
            add(_AuthSessionCleared());
          }
        });

        // Verificar usuario actual al inicio
        if (session != null) {
          try {
            await authRepository.ensureCurrentUserRow();
            final userFromDB = await authRepository.getCurrentUserFromBd();
            if (userFromDB != null) {
              emit(AuthAuthenticated(userFromDB));
            } else {
              final user = authRepository.currentUser();
              if (user != null) {
                emit(AuthAuthenticated(user));
              } else {
                emit(AuthUnauthenticated());
              }
            }
          } catch (e) {
            // ignore: avoid_print
            print('Error al iniciar sesión: auth_bloc line 45: $e');
            final user = authRepository.currentUser();
            if (user != null) {
              emit(AuthAuthenticated(user));
            } else {
              emit(AuthUnauthenticated());
            }
          }
        }
      } catch (e) {
        emit(AuthError('Error iniciando estado de sesión: $e'));
        emit(AuthUnauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signIn(event.email, event.password);
        
        // Después del sign in, obtener el usuario completo desde la BD
        final userFromDB = await authRepository.getCurrentUserFromBd();
        if (userFromDB != null) {
          emit(AuthAuthenticated(userFromDB));
        } else {
          final user = authRepository.currentUser();
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            throw Exception('No se pudo obtener información del usuario');
          }
        }
      } catch (e) {
        emit(AuthError('No se pudo iniciar sesión. Error: $e'));
        emit(AuthUnauthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final exists = await authRepository.existsUserRoot();
        if (exists) {
          emit(AuthError('Ya existe un usuario root'));
          emit(AuthUnauthenticated());
          return;
        }
        
        await authRepository.signUp(event.email, event.password, event.name, event.role);
        
        // Después del sign up, obtener el usuario completo desde la BD
        final userFromDB = await authRepository.getCurrentUserFromBd();
        if (userFromDB != null) {
          emit(AuthAuthenticated(userFromDB));
        } else {
          final user = authRepository.currentUser();
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            throw Exception('No se pudo obtener información del usuario después del registro');
          }
        }
      } catch (e) {
        emit(AuthError('No se pudo crear el usuario. Error: $e'));
        emit(AuthUnauthenticated());
      }
    });

    on<CreateUserRequested>((event, emit) async {
      final currentState = state;
      emit(AuthLoading());
      
      try {
        final exists = await authRepository.existsUserRoot();
        if (exists && event.role == UserRole.root) {
          emit(AuthError('Ya existe un usuario root'));
          // Mantener el estado anterior
          emit(currentState);
          return;
        }
        
        await authRepository.signUp(event.email, event.password, event.name, event.role);
        
        // Emitir success sin cambiar a authenticated
        emit(AuthUserCreated('Usuario creado exitosamente'));
        
        // Volver al estado anterior
        emit(currentState);
        
      } catch (e) {
        emit(AuthError('No se pudo crear el usuario. Error: $e'));
        // Volver al estado anterior
        emit(currentState);
      }
    });

    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    });

    // Internal events
    on<_AuthSessionArrived>((event, emit) => emit(AuthAuthenticated(event.user)));
    on<_AuthSessionCleared>((event, emit) => emit(AuthUnauthenticated()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _AuthSessionArrived extends AuthEvent {
  final dynamic user;
  _AuthSessionArrived({required this.user});
}

class _AuthSessionCleared extends AuthEvent {}