import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _subscription;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthStarted>((event, emit) {
      _subscription?.cancel();
      _subscription = authRepository.getAuthStateChanges().listen((user) {
        if (user != null) {
          add(_AuthSessionArrived(user: user));
        } else {
          add(_AuthSessionCleared());
        }
      });
      final user = authRepository.currentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
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
        final user = await authRepository.signUp(event.email, event.password);
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