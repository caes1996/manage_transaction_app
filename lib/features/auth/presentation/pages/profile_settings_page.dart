import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/core/utils/functions.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
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
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y seguridad'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary.withValues(alpha: 0.03),
              context.surface,
              context.primary.withValues(alpha: 0.01),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              if (context.isDesktop) {
                return _buildDesktopView(state.user);
              } else if (context.isTablet) {
                return _buildTabletView(state.user);
              } else {
                return _buildMobileView(state.user);
              }
            }
            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopView(dynamic user) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildProfileCard(user),
                  const SizedBox(height: 24),
                  _buildQuickStatsCard(user),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Panel derecho - Detalles y acciones
            Expanded(
              flex: 3,
              child: _buildUserDetailsCard(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletView(dynamic user) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 24,
          children: [
            Row(
              spacing: 20,
              children: [
                Expanded(child: _buildProfileCard(user)),
                Expanded(child: _buildQuickStatsCard(user)),
              ],
            ),
            _buildUserDetailsCard(user),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView(dynamic user) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            _buildProfileCard(user),
            _buildUserDetailsCard(user),
            _buildQuickStatsCard(user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserEntity user) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary,
              context.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar del usuario
            Container(
              width: context.isDesktop ? 100 : 80,
              height: context.isDesktop ? 100 : 80,
              decoration: BoxDecoration(
                color: context.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: context.onPrimary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Icon(
                HugeIcons.strokeRoundedUser,
                size: context.isDesktop ? 48 : 40,
                color: context.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre del usuario
            Text(
              user.name,
              style: (context.isDesktop 
                  ? context.titleSmall 
                  : context.titleLarge).copyWith(
                color: context.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Rol del usuario
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: context.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.displayName.capitalize,
                style: context.bodyMedium.copyWith(
                  color: context.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  HugeIcons.strokeRoundedMail01,
                  size: 16,
                  color: context.onPrimary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    user.email,
                    style: context.bodySmall.copyWith(
                      color: context.onPrimary.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(UserEntity user) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  HugeIcons.strokeRoundedAnalytics02,
                  color: context.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Información de Cuenta',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatItem(
              icon: HugeIcons.strokeRoundedCalendar03,
              label: 'Miembro desde',
              value: _formatCreatedAt(user.createdAt),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              icon: HugeIcons.strokeRoundedShield01,
              label: 'Nivel de acceso',
              value: user.role.displayName.capitalize,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              label: 'Estado',
              value: 'Activo',
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(UserEntity user) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  HugeIcons.strokeRoundedUserSettings01,
                  color: context.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalles de Perfil',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedUser,
              label: 'Nombre completo',
              value: user.name,
            ),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedMail01,
              label: 'Correo electrónico',
              value: user.email,
            ),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedUserStar01,
              label: 'Rol del usuario',
              value: user.role.displayName.capitalize,
            ),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedCalendar03,
              label: 'Fecha de registro',
              value: _formatCreatedAt(user.createdAt),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      spacing: 12,
      children: [
        Icon(
          icon,
          size: 20,
          color: context.primary.withValues(alpha: 0.7),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.bodySmall.copyWith(
                  color: context.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? context.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: context.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.bodySmall.copyWith(
                        color: context.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: context.primary.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando perfil...',
            style: context.titleMedium.copyWith(
              color: context.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(dynamic createdAt) {
    if (createdAt == null) return 'Fecha no disponible';
    
    try {
      if (createdAt is DateTime) {
        return Utils.formatDate(createdAt);
      } else if (createdAt is String) {
        final date = DateTime.parse(createdAt);
        return Utils.formatDate(date);
      }
      return 'Fecha no disponible';
    } catch (e) {
      return 'Fecha no disponible';
    }
  }
}