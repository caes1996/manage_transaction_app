import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/layouts/app_shell.dart';

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

  GoRouter _build() {
    return GoRouter(
      navigatorKey: _navKey,
      initialLocation: AppRoutes.login,
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final s = _authBloc.state;
        final loc = state.matchedLocation;
        final goingToLogin = loc == AppRoutes.login;

        bool isProtected(String p) =>
            p.startsWith(AppRoutes.dashboard) ||
            p.startsWith(AppRoutes.transactions) ||
            p.startsWith(AppRoutes.users) ||
            p.startsWith(AppRoutes.settings);

        if (s is AuthAuthenticated) {
          if (goingToLogin) return AppRoutes.dashboard;
          return null;
        }

        if (s is AuthUnauthenticated || s is AuthError) {
          if (!goingToLogin && isProtected(loc)) {
            return AppRoutes.login;
          }
          return null;
        }

        return null;
      },

      routes: [
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
