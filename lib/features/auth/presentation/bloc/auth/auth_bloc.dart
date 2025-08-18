import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/auth/data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
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
          } catch (_) {
            // ignore: avoid_print
            print('Error al iniciar sesión: auth_bloc line 19');
          }
          emit(AuthAuthenticated(UserModel.fromSupabaseUser(session.user)));
        } else {
          emit(AuthUnauthenticated());
        }

        _subscription?.cancel();
        _subscription = authRepository.getAuthStateChanges().listen((user) async {
          if (user != null) {
            try {
              await authRepository.ensureCurrentUserRow();
            } catch (_) {
              // ignore: avoid_print
              print('Error al iniciar sesión: auth_bloc line 32');
            }
            add(_AuthSessionArrived(user: user));
          } else {
            add(_AuthSessionCleared());
          }
        });

        final user = authRepository.currentUser();
        if (user != null) {
          try {
            await authRepository.ensureCurrentUserRow();
          } catch (_) {
            // ignore: avoid_print
            print('Error al iniciar sesión: auth_bloc line 45');
          }
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        // Nunca te quedes en AuthInitial
        emit(AuthError('Error iniciando estado de sesión: $e'));
        emit(AuthUnauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signIn(event.email, event.password);
        emit(AuthAuthenticated(user));
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
        final user = await authRepository.signUp(event.email, event.password, event.name, event.role);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError('No se pudo crear el usuario. Error: $e'));
        emit(AuthUnauthenticated());
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