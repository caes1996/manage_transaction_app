import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/layouts/app_shell.dart';
import 'package:manage_transaction_app/features/auth/presentation/pages/splash_page.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_state.dart';

import '../../../features/transactions/presentation/pages/transactions_page_stub.dart';
import '../../../features/auth/presentation/pages/users_page_stub.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page_stub.dart';
import '../../../features/settings/presentation/settings_home_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }
  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const users = '/users';
  static const settings = '/settings';
  static String settingsSection(String id) => '/settings/$id';
}

class AppRouter {
  AppRouter._(this._authBloc);

  /// Crea el router inyectando el AuthBloc (¡clave para conservar sesión!).
  static GoRouter create(AuthBloc authBloc) => AppRouter._(authBloc)._build();

  final AuthBloc _authBloc;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  bool _isAuthKnown(AuthState? s) => s is AuthAuthenticated || s is AuthUnauthenticated || s is AuthError;

  GoRouter _build() {
    return GoRouter(
      navigatorKey: _navKey,
      initialLocation: AppRoutes.splash,
      // Refresca rutas cuando cambia el estado de autenticación
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final authState = _authBloc.state;
        final goingToLogin = state.matchedLocation == AppRoutes.login;
        final goingToSplash = state.matchedLocation == AppRoutes.splash;

        // 1) Mientras no sepamos el estado, quédate en Splash
        if (!_isAuthKnown(authState)) {
          return goingToSplash ? null : AppRoutes.splash;
        }

        // 2) Si está autenticado:
        if (authState is AuthAuthenticated) {
          // - Evita estar en Splash/Login; mándalo al Dashboard
          if (goingToSplash || goingToLogin) return AppRoutes.dashboard;
          return null; // continúa a lo que sea
        }

        // 3) Si NO está autenticado:
        if (authState is AuthUnauthenticated) {
          // - Permite estar en Login o Splash
          if (goingToLogin || goingToSplash) return null;
          // - Bloquea rutas protegidas
          return AppRoutes.login;
        }

        // Fallback (no debería llegar)
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, _) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, _) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              builder: (context, _) => const DashboardPageStub(),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              name: 'transactions',
              builder: (context, _) => const TransactionsPageStub(),
            ),
            GoRoute(
              path: AppRoutes.users,
              name: 'users',
              builder: (context, _) => const UsersPageStub(),
            ),
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              builder: (context, _) => const SettingsHomePage(),
            ),
            GoRoute(
              path: '/settings/:sectionId',
              name: 'settings-section',
              builder: (context, state) {
                final id = state.pathParameters['sectionId']!;
                return SettingsSectionPage(id: id);
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(HugeIcons.strokeRoundedAlertCircle, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Text('${state.error}'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
