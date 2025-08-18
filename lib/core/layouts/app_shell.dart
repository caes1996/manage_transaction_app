import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFromPath(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 0;
    if (location.startsWith(AppRoutes.users)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 3;
  }

  void _goTo(int i, BuildContext context) {
    switch (i) {
      case 0:
        context.go(AppRoutes.transactions);
        break;
      case 1:
        context.go(AppRoutes.users);
        break;
      case 2:
        context.go(AppRoutes.settings);
        break;
      default:
        context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {

    final uri = GoRouterState.of(context).uri.toString();
    final idx = _indexFromPath(uri);

    final appBar = AppBar(title: const Text('Manage Transaction App'));

    // --- MÓVIL: NavigationBar inferior
    if (context.isMobile) {
      return Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => _goTo(i, context),
          destinations: const [
            NavigationDestination(icon: Icon(HugeIcons.strokeRoundedArrowDataTransferHorizontal), label: 'Transactions'),
            NavigationDestination(icon: Icon(HugeIcons.strokeRoundedUserMultiple02), label: 'Users'),
            NavigationDestination(icon: Icon(HugeIcons.strokeRoundedSettings04), label: 'Settings'),
            NavigationDestination(icon: Icon(HugeIcons.strokeRoundedDashboardSquare02), label: 'Dashboard'),
          ],
        ),
      );
    }

    // --- TABLET / DESKTOP: NavigationRail lateral
    final rail = NavigationRail(
      selectedIndex: idx,
      onDestinationSelected: (i) => _goTo(i, context),
      // En desktop se muestra extendido (ícono + texto)
      extended: context.isDesktop,
      // En tablet solo etiqueta seleccionada
      labelType: context.isTablet ? NavigationRailLabelType.selected : NavigationRailLabelType.none,
      leading: SafeArea(
        bottom: false,
        child: IconButton(
          tooltip: 'Dashboard',
          icon: const Icon(HugeIcons.strokeRoundedHome01),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(HugeIcons.strokeRoundedArrowDataTransferHorizontal),
          selectedIcon: Icon(HugeIcons.strokeRoundedArrowDataTransferHorizontal, size: 28),
          label: Text('Transactions'),
        ),
        NavigationRailDestination(
          icon: Icon(HugeIcons.strokeRoundedUserMultiple02),
          selectedIcon: Icon(HugeIcons.strokeRoundedUserMultiple02, size: 28),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(HugeIcons.strokeRoundedSettings04),
          selectedIcon: Icon(HugeIcons.strokeRoundedSettings04, size: 28),
          label: Text('Settings'),
        ),
        NavigationRailDestination(
          icon: Icon(HugeIcons.strokeRoundedDashboardSquare02),
          selectedIcon: Icon(HugeIcons.strokeRoundedDashboardSquare02, size: 28),
          label: Text('Dashboard'),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          // Rail fijo a la izquierda
          SafeArea(child: rail),
          const VerticalDivider(width: 1),
          // Contenido
          Expanded(
            child: Padding(
              // Más aire en desktop
              padding: EdgeInsets.all(context.isDesktop ? 24 : 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
