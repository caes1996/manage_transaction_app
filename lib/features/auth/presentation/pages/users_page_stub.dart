import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/core/utils/functions.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_state.dart';
import 'package:manage_transaction_app/features/auth/presentation/widgets/user_form_modal.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';

class UsersPageStub extends StatefulWidget {
  const UsersPageStub({super.key});

  @override
  State<UsersPageStub> createState() => _UsersPageStubState();
}

class _UsersPageStubState extends State<UsersPageStub> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    context.read<UserBloc>().add(UsersWatchRequested());
    _animationController.forward();
  }

  @override
  void dispose() {
    context.read<UserBloc>().add(UsersStopWatching());
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (context.isDesktop) {
          return _buildDesktopView(state);
        } else if (context.isTablet) {
          return _buildTabletView(state);
        } else {
          return _buildMobileView(state);
        }
      },
    );
  }

  // ===================== VISTAS RESPONSIVAS =====================

  Widget _buildDesktopView(UserState state) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDesktopHeader(),
            _buildSubHeader(state),
            Expanded(child: _buildDesktopContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletView(UserState state) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildTabletHeader(),
            _buildSubHeader(state),
            Expanded(child: _buildTabletContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView(UserState state) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 8),
            _buildTextTotalUsers(state),
            Expanded(child: _buildMobileContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTotalUsers(UserState state) {
    if (state is UsersLoaded) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          'Total de usuarios: ${state.users.length}',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSubHeader(UserState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextTotalUsers(state),
        _buildButtonCreateUser(),
      ],
    );
  }

  Widget _buildButtonCreateUser() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserEntity? currentUser;
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        }

        return currentUser?.role != UserRole.transactional
          ? SizedBox(
            width: 200,
            child: CustomButton(
              label: 'Crear usuario',
              leading: Icon(HugeIcons.strokeRoundedAdd01, color: context.onPrimary),
              margin: const EdgeInsets.only(top: 16, right: 16),
              onTap: () => ModalHelper.showUserFormModal(context),
            ),
          )
          : const SizedBox.shrink();
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserEntity? currentUser;
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        }

        return currentUser?.role != UserRole.transactional
          ? FloatingActionButton(
            onPressed: () => ModalHelper.showUserFormModal(context),
            tooltip: 'Crear usuario',
            child: const Icon(HugeIcons.strokeRoundedAdd01),
          )
          : const SizedBox.shrink();
      },
    );
  }

  // ===================== HEADERS ESPECÍFICOS =====================

  Widget _buildDesktopHeader() {
    return Container(
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 28, subtitleSize: 16),
                ),
                _buildViewToggleButton(),
                const SizedBox(width: 16),
                SizedBox(
                  width: 350,
                  child: _buildSearchBar(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 26, subtitleSize: 15),
                ),
                _buildViewToggleButton(),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 24, subtitleSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  // ===================== CONTENIDO ESPECÍFICO =====================

  Widget _buildDesktopContent(UserState state) {
    if (state is UserLoading) return _buildLoadingState();
    if (state is UserError) return _buildErrorState(state.message);

    if (state is UsersLoaded) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: _isGridView 
            ? _buildUsersGrid(state.users, crossAxisCount: 4, childAspectRatio: 0.8)
            : _buildUsersList(state.users, itemPadding: 8),
      );
    }

    return _buildDefaultState();
  }

  Widget _buildTabletContent(UserState state) {
    if (state is UserLoading) return _buildLoadingState();
    if (state is UserError) return _buildErrorState(state.message);

    if (state is UsersLoaded) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _isGridView 
            ? _buildUsersGrid(state.users, crossAxisCount: 3, childAspectRatio: 0.75)
            : _buildUsersList(state.users, itemPadding: 6),
      );
    }

    return _buildDefaultState();
  }

  Widget _buildMobileContent(UserState state) {
    if (state is UserLoading) return _buildLoadingState();
    if (state is UserError) return _buildErrorState(state.message);

    if (state is UsersLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: _buildUsersList(state.users, itemPadding: 4),
      );
    }

    return _buildDefaultState();
  }

  // ===================== WIDGETS COMUNES REUTILIZABLES =====================

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        HugeIcons.strokeRoundedUserMultiple02,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildHeaderTitles({required double titleSize, required double subtitleSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Usuarios',
          style: context.titleLarge.copyWith(
            color: context.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Administra y controla los usuarios del sistema',
          style: context.bodyMedium.copyWith(
            color: context.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isGridView = !_isGridView;
        });
      },
      icon: Icon(
        _isGridView 
            ? HugeIcons.strokeRoundedMenu02 
            : HugeIcons.strokeRoundedGrid,
        color: Colors.white,
      ),
      tooltip: _isGridView ? 'Vista de Lista' : 'Vista de Rejilla',
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.onPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: context.bodyMedium.copyWith(
          color: context.onPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          hintStyle: context.bodyMedium.copyWith(
            color: context.onPrimary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            HugeIcons.strokeRoundedSearch01,
            color: context.onPrimary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUsersGrid(List<dynamic> users, {required int crossAxisCount, required double childAspectRatio}) {
    final filteredUsers = _getFilteredUsers(users);

    if (filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(filteredUsers[index], isCompact: true);
      },
    );
  }

  Widget _buildUsersList(List<dynamic> users, {required double itemPadding}) {
    final filteredUsers = _getFilteredUsers(users);

    if (filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(filteredUsers[index], isCompact: false);
      },
    );
  }

  Widget _buildUserCard(UserEntity user, {required bool isCompact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 8 : 4,
        vertical: 6,
      ),
      child: Card(
        elevation: 2,
        shadowColor: context.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetails(user),
          child: Container(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: isCompact 
                ? _buildCompactUserContent(user) 
                : _buildFullUserContent(user),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactUserContent(UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserAvatar(user, size: 60, fontSize: 24),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: context.titleMedium.copyWith(
            color: context.secondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: context.bodySmall.copyWith(
            color: context.secondary.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildRoleChip(user.role),
      ],
    );
  }

  Widget _buildFullUserContent(UserEntity user) {
    return Row(
      children: [
        _buildUserAvatar(user, size: 56, fontSize: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: context.titleMedium.copyWith(
                  color: context.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    HugeIcons.strokeRoundedMail01,
                    size: 14,
                    color: context.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.email,
                      style: context.bodySmall.copyWith(
                        color: context.secondary.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildRoleChip(user.role),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role) {
    final colorChip = switch (role) {
      UserRole.root => const Color(0xFFC52E23),
      UserRole.admin => const Color(0xFF197DCF),
      UserRole.transactional => const Color(0xFF1F7A22),
    };
    return Chip(
      backgroundColor: colorChip,
      label: SizedBox(
        width: 80,
        child: Text(
          role.name.capitalize,
          textAlign: TextAlign.center,
          style: context.bodySmall.copyWith(
            color: colorChip.contrast,
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserEntity user, {required double size, required double fontSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? Utils.getInitials(user.name) : '--',
          style: context.titleLarge.copyWith(
            color: context.onPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedSearchRemove,
              size: 48,
              color: context.secondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron usuarios',
            style: context.titleMedium.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay usuarios registrados en el sistema'
                : 'Intenta con otros términos de búsqueda',
            style: context.bodySmall.copyWith(
              color: context.secondary.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            'Cargando usuarios...',
            style: context.titleMedium.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(context.isDesktop ? 32 : 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.error.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedAlert02,
                size: 32,
                color: context.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar usuarios',
              style: context.titleMedium.copyWith(
                color: context.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodySmall.copyWith(
                color: context.secondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserBloc>().add(GetAllUsersRequested());
              },
              icon: const Icon(HugeIcons.strokeRoundedRefresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedUserMultiple02,
              size: 48,
              color: context.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Módulo de Usuarios',
            style: context.titleMedium.copyWith(
              color: context.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema en desarrollo',
            style: context.bodySmall.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MÉTODOS AUXILIARES =====================

  List<UserEntity> _getFilteredUsers(List<dynamic> users) {
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery) ||
             user.email.toLowerCase().contains(_searchQuery);
    }).cast<UserEntity>().toList();
  }

  void _showUserDetails(UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildUserAvatar(user, size: 40, fontSize: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Detalles del Usuario',
                style: context.titleMedium.copyWith(
                  color: context.secondary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nombre', user.name),
            const SizedBox(height: 12),
            _buildDetailRow('Email', user.email),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: context.bodyMedium.copyWith(
                color: context.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.bodySmall.copyWith(
            color: context.secondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.bodyMedium.copyWith(
            color: context.secondary,
          ),
        ),
      ],
    );
  }
}