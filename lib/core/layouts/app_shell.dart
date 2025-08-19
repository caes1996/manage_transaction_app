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
    if (location.startsWith(AppRoutes.profile)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _goTo(int i, BuildContext context) {
    switch (i) {
      case 0: context.go(AppRoutes.transactions); break;
      case 1: context.go(AppRoutes.users); break;
      case 2: context.go(AppRoutes.profile); break;
      case 3: context.go(AppRoutes.settings); break;
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: context.primary.withValues(alpha: 0.1),
      title: Text(
        'Manage Transaction App',
        style: context.titleLarge.copyWith(
          fontSize: context.isDesktop ? 22 : 20,
          fontWeight: FontWeight.w600,
          color: context.secondary,
        ),
      ),
      centerTitle: context.isMobile,
    );
  }

  Widget _buildMobileNavigation(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: context.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: context.surface,
        indicatorColor: context.primary.withValues(alpha: 0.12),
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _goTo(i, context),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          NavigationDestination(
            icon: Icon(
              HugeIcons.strokeRoundedArrowDataTransferHorizontal,
              color: context.primary.withValues(alpha: 0.7),
            ),
            selectedIcon: Icon(
              HugeIcons.strokeRoundedArrowDataTransferHorizontal,
              color: context.primary,
            ),
            label: 'Transacciones',
          ),
          NavigationDestination(
            icon: Icon(
              HugeIcons.strokeRoundedUserMultiple02,
              color: context.primary.withValues(alpha: 0.7),
            ),
            selectedIcon: Icon(
              HugeIcons.strokeRoundedUserMultiple02,
              color: context.primary,
            ),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(
              HugeIcons.strokeRoundedUserMultiple02,
              color: context.primary.withValues(alpha: 0.7),
            ),
            selectedIcon: Icon(
              HugeIcons.strokeRoundedUserMultiple02,
              color: context.primary,
            ),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(
              HugeIcons.strokeRoundedSettings04,
              color: context.primary.withValues(alpha: 0.7),
            ),
            selectedIcon: Icon(
              HugeIcons.strokeRoundedSettings04,
              color: context.primary,
            ),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRail(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: context.surface.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        backgroundColor: Colors.white,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _goTo(i, context),
        extended: context.isDesktop,
        labelType: context.isTablet 
            ? NavigationRailLabelType.selected 
            : NavigationRailLabelType.none,
        selectedIconTheme: IconThemeData(color: context.primary, size: 28),
        unselectedIconTheme: IconThemeData(color: context.primary.withValues(alpha: 0.7), size: 24),
        selectedLabelTextStyle: context.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: context.primary,
        ),
        unselectedLabelTextStyle: context.bodySmall.copyWith(
          fontWeight: FontWeight.w400,
          color: context.secondary.withValues(alpha: 0.7),
        ),
        indicatorColor: context.primary.withValues(alpha: 0.12),
        useIndicator: true,
        minWidth: context.isTablet ? 72 : 56,
        minExtendedWidth: 256,
        leading: Container(
          margin: const EdgeInsets.only(bottom: 16, top: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  HugeIcons.strokeRoundedUserAccount,
                  color: context.primary,
                  size: context.isDesktop ? 36 : 24,
                ),
              ),
              if (context.isDesktop) ...[
                const SizedBox(height: 8),
                Text(
                  'Dashboard',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        destinations: [
          NavigationRailDestination(
            icon: const Icon(HugeIcons.strokeRoundedArrowDataTransferHorizontal),
            selectedIcon: const Icon(HugeIcons.strokeRoundedArrowDataTransferHorizontal),
            label: const Text('Transacciones'),
          ),
          NavigationRailDestination(
            icon: const Icon(HugeIcons.strokeRoundedUserMultiple02),
            selectedIcon: const Icon(HugeIcons.strokeRoundedUserMultiple02),
            label: const Text('Usuarios'),
          ),
          NavigationRailDestination(
            icon: const Icon(HugeIcons.strokeRoundedUserMultiple02),
            selectedIcon: const Icon(HugeIcons.strokeRoundedUserMultiple02),
            label: const Text('Perfil'),
          ),
          NavigationRailDestination(
            icon: const Icon(HugeIcons.strokeRoundedSettings04),
            selectedIcon: const Icon(HugeIcons.strokeRoundedSettings04),
            label: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexFromPath(uri);

    // Configuración del tema para toda la app
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: context.surface,
        cardColor: Colors.white,
        dividerColor: context.surface.withValues(alpha: 0.5),
      ),
      child: Builder(
        builder: (context) {
          // --- MÓVIL: NavigationBar inferior
          if (context.isMobile) {
            return Scaffold(
              backgroundColor: context.surface,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: _buildAppBar(context),
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: context.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
              bottomNavigationBar: _buildMobileNavigation(context, selectedIndex),
            );
          }

          // --- TABLET / DESKTOP: NavigationRail lateral
          return Scaffold(
            backgroundColor: context.surface,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: _buildAppBar(context),
            ),
            body: Row(
              children: [
                // Rail fijo a la izquierda
                _buildDesktopRail(context, selectedIndex),
                
                // Contenido principal
                Expanded(
                  child: Container(
                    color: context.surface,
                    child: SafeArea(
                      left: false,
                      child: Padding(
                        padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: context.primary.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}