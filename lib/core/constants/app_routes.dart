import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/layouts/app_shell.dart';
import 'package:manage_transaction_app/features/auth/presentation/presentation.dart';
import 'package:manage_transaction_app/features/design_system/inputs/custom_button.dart';
import 'package:manage_transaction_app/features/transactions/presentation/presentation.dart';
import 'package:manage_transaction_app/features/settings/presentation/settings_home_page.dart';

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
  static const login = '/login';
  static const transactions = '/transactions';
  static const users = '/users';
  static const profile = '/profile';
  static const settings = '/settings';
}

class AppRouter {
  AppRouter._(this._authBloc);

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
            p.startsWith(AppRoutes.transactions) ||
            p.startsWith(AppRoutes.users) ||
            p.startsWith(AppRoutes.settings);

        if (s is AuthAuthenticated) {
          if (goingToLogin) return AppRoutes.transactions;
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
        GoRoute(path: AppRoutes.login, name: 'login', builder: (context, _) => const LoginPage()),
        ShellRoute(builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: AppRoutes.transactions, name: 'transactions', builder: (context, _) => const TransactionsPage()),
            GoRoute(path: AppRoutes.users, name: 'users', builder: (context, _) => const UsersPage()),
            GoRoute(path: AppRoutes.profile, name: 'profile', builder: (context, _) => const ProfilePage()),
            GoRoute(path: AppRoutes.settings, name: 'settings', builder: (context, _) => const SettingsHomePage()),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(HugeIcons.strokeRoundedAlertCircle, size: 64, color: Colors.red),
              Text('${state.error}'),
              CustomButton(
                label: 'Ir al inicio',
                onTap: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
