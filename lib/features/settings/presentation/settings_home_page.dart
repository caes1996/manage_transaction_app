import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/design_system/inputs/custom_button.dart';

class SettingsHomePage extends StatefulWidget {
  const SettingsHomePage({super.key});

  @override
  State<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _buildDesktopView();
    } else if (context.isTablet) {
      return _buildTabletView();
    } else {
      return _buildMobileView();
    }
  }

  Widget _buildDesktopView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary.withValues(alpha: 0.05),
              context.surface,
              context.primary.withValues(alpha: 0.02),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _buildInfoPanel()),
            Expanded(child: _buildSignOutForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary.withValues(alpha: 0.05),
              context.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: _buildInfoPanel(),
            ),
            Expanded(child: _buildSignOutForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary.withValues(alpha: 0.08),
              context.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildSignOutForm(),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.all(context.isDesktop ? 48 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.isDesktop 
            ? const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              )
            : const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedUserCheck01,
                  size: context.isDesktop ? 56 : 48,
                  color: context.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hasta pronto!',
                    style: (context.isDesktop 
                        ? context.bodySmall 
                        : context.titleLarge).copyWith(
                      color: context.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu sesión se cerrará de forma segura y todos tus datos quedarán protegidos.',
                    style: (context.isDesktop 
                        ? context.bodyMedium 
                        : context.bodySmall).copyWith(
                      color: context.onPrimary.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  if (context.isDesktop) ...[
                    const SizedBox(height: 12),
                    _buildFeaturesList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Datos seguros y protegidos',
      'Sesión cerrada correctamente',
      'Acceso rápido para volver',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedCheckmarkCircle02,
                size: 20,
                color: context.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: context.bodySmall.copyWith(
                  color: context.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSignOutForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Future.delayed(const Duration(milliseconds: 800), () {
            // ignore: use_build_context_synchronously
            context.go(AppRoutes.login);
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.isDesktop ? 48 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (context.isMobile) ...[
                  _buildMobileHeader(),
                  const SizedBox(height: 32),
                ],
                
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSignOutCard(isLoading, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            HugeIcons.strokeRoundedLogout04,
            size: 48,
            color: context.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cerrar Sesión',
          style: context.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: context.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutCard(bool isLoading, AuthState state) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: context.isDesktop ? 500 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.primary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              _buildLoadingContent(),
            ] else if (state is AuthError) ...[
              _buildErrorContent(state.message),
            ] else ...[
              _buildConfirmationContent(isLoading),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationContent(bool isLoading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            HugeIcons.strokeRoundedAlert01,
            size: 48,
            color: context.error.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¿Estás seguro?',
          style: (context.isDesktop 
              ? context.titleSmall 
              : context.titleLarge).copyWith(
            fontWeight: FontWeight.bold,
            color: context.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tu sesión se cerrará y deberás iniciar sesión nuevamente para acceder a la aplicación.',
          style: context.bodyMedium.copyWith(
            color: context.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildActionButtons(isLoading),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.primary),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Cerrando sesión...',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por favor espera un momento',
          style: context.bodyMedium.copyWith(
            color: context.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(String message) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            HugeIcons.strokeRoundedAlert02,
            size: 48,
            color: context.error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Error al cerrar sesión',
          style: context.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: context.error,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: context.bodyMedium.copyWith(
            color: context.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildActionButtons(false),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return CustomButton(
      onTap: isLoading ? null : _handleSignOut,
      label: 'Cerrar sesión',
      color: context.error,
      leading: Icon(
        HugeIcons.strokeRoundedLogout04,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  void _handleSignOut() {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(SignOutRequested());
  }
}