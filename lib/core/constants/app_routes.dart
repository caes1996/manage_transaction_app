import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/layouts/app_shell.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';

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
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const users = '/users';
  static const settings = '/settings';
  static String settingsSection(String id) => '/settings/$id';
}

class AppRouter {
  AppRouter._();
  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(
      _authStream,
    ),
    redirect: (context, state) {
      final authState = _authState(context);
      final goingToAuth = state.matchedLocation == AppRoutes.login;

      if (authState is AuthAuthenticated && goingToAuth) {
        return AppRoutes.dashboard;
      }
      if (authState is! AuthAuthenticated && !goingToAuth) {
        return AppRoutes.login;
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

  // Helpers privados
  Stream<dynamic> get _authStream => _authBloc?.stream ?? const Stream.empty();
  AuthBloc? get _authBloc => _navKey.currentContext?.read<AuthBloc>();
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  AuthState? _authState(BuildContext context) {
    try { return context.read<AuthBloc>().state; } catch (_) { return null; }
  }
}
