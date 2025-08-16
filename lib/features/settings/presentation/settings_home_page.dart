import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:manage_transaction_app/features/auth/presentation/pages/profile_settings_page.dart';
import 'package:manage_transaction_app/features/settings/presentation/app_preferences_page.dart';
import 'package:manage_transaction_app/features/transactions/presentation/pages/transactions_settings_page.dart';

class SettingsHomePage extends StatelessWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item('Perfil y seguridad', HugeIcons.strokeRoundedUser03,
          () => context.go(AppRoutes.settingsSection('profile'))),
      _Item('Preferencias de la app', HugeIcons.strokeRoundedSlidersHorizontal,
          () => context.go(AppRoutes.settingsSection('app'))),
      _Item('Ajustes de transacciones', HugeIcons.strokeRoundedArrowDataTransferHorizontal,
          () => context.go(AppRoutes.settingsSection('transactions'))),
      _Item('Cerrar sesión', HugeIcons.strokeRoundedLogout04,
          () => context.go(AppRoutes.settingsSection('signout'))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            leading: Icon(it.icon),
            title: Text(it.title),
            trailing: Icon(HugeIcons.strokeRoundedArrowRight01),
            onTap: it.onTap,
          );
        },
      ),
    );
  }
}

class SettingsSectionPage extends StatelessWidget {
  const SettingsSectionPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    switch (id) {
      case 'profile':
        return const _SectionWrapper(child: ProfileSettingsPage());
      case 'app':
        return const _SectionWrapper(child: AppPreferencesPage());
      case 'transactions':
        return const _SectionWrapper(child: TransactionsSettingsPage());
      case 'signout':
        return const _SignOutPage();
      default:
        return _NotFound(sectionId: id);
    }
  }
}

class _Item {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _Item(this.title, this.icon, this.onTap);
}

class _SectionWrapper extends StatelessWidget {
  const _SectionWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: child);
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.sectionId});
  final String sectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(HugeIcons.strokeRoundedAiSetting, size: 56),
            const SizedBox(height: 12),
            Text('Sección no encontrada: $sectionId'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.settings),
              child: const Text('Volver a Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignOutPage extends StatelessWidget {
  const _SignOutPage();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cerrar sesión')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(HugeIcons.strokeRoundedLogout04, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Estás seguro que deseas cerrar sesión?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              loading ? null : () => context.go(AppRoutes.settings),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              loading ? null : () => authBloc.add(SignOutRequested()),
                          icon: const Icon(HugeIcons.strokeRoundedLogout04),
                          label: Text(loading ? 'Cerrando...' : 'Cerrar sesión'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
