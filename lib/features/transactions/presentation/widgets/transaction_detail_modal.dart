import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/core/utils/functions.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_state.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionDetailModal extends StatefulWidget {
  final TransactionEntity transaction;
  
  const TransactionDetailModal({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final Color _approvedColor = const Color(0xFF10B981);
  final Color _rejectedColor = const Color(0xFFEF4444);

  // Variables responsivas
  double _getModalWidth(BuildContext context) {
    if (context.isMobile) return MediaQuery.of(context).size.width * 0.95;
    if (context.isTablet) return 650.0;
    return 600.0; // Desktop
  }

  EdgeInsets _getModalPadding(BuildContext context) {
    if (context.isMobile) return const EdgeInsets.all(20.0);
    if (context.isTablet) return const EdgeInsets.all(28.0);
    return const EdgeInsets.all(32.0); // Desktop
  }

  double _getTitleSize(BuildContext context) {
    if (context.isMobile) return 22.0;
    if (context.isTablet) return 24.0;
    return 26.0; // Desktop
  }

  double _getButtonHeight(BuildContext context) {
    if (context.isMobile) return 48.0;
    if (context.isTablet) return 52.0;
    return 56.0; // Desktop
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionUpdated) {
          _showSnackBar(
            context,
            'Estado de transacción actualizado exitosamente',
            Colors.green,
            Icons.check_circle,
          );
          // Cerrar el modal después de un breve delay
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              // ignore: use_build_context_synchronously
              context.pop();
            }
          });
        } else if (state is TransactionError) {
          _showSnackBar(
            context,
            state.message,
            Colors.red,
            Icons.error,
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? 16.0 : 40.0,
          vertical: context.isMobile ? 24.0 : 40.0,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: _getModalWidth(context),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                maxWidth: context.isMobile ? double.infinity : 650,
              ),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(context.isMobile ? 16.0 : 20.0),
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: _getModalPadding(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context, state),
                        const SizedBox(height: 24),
                        _buildTransactionInfo(context),
                        const SizedBox(height: 24),
                        _buildAmountSection(context),
                        const SizedBox(height: 24),
                        _buildStatusSection(context),
                        const SizedBox(height: 24),
                        _buildMetadata(context),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, state),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransactionState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedExchange03,
                  color: context.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de Transacción',
                      style: TextStyle(
                        fontSize: _getTitleSize(context),
                        fontWeight: FontWeight.bold,
                        color: context.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: #${widget.transaction.id}',
                      style: context.bodySmall.copyWith(
                        color: context.secondary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _isLoading(state) ? null : () => context.pop(),
          icon: Icon(
            Icons.close,
            size: context.isMobile ? 22 : 24,
            color: _isLoading(state) 
                ? Colors.grey 
                : context.secondary.withValues(alpha: 0.7),
          ),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildTransactionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Título',
            widget.transaction.title,
            HugeIcons.strokeRoundedFile02,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Concepto',
            widget.transaction.concept,
            HugeIcons.strokeRoundedNote,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary.withValues(alpha: 0.1),
            context.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              HugeIcons.strokeRoundedDollarCircle,
              color: context.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monto de la Transacción',
                  style: context.bodyMedium.copyWith(
                    color: context.secondary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${widget.transaction.amount.toStringAsFixed(2)}',
                  style: context.bodyLarge.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.transaction.status).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(widget.transaction.status).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.transaction.status).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(widget.transaction.status),
              color: _getStatusColor(widget.transaction.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado Actual',
                  style: context.bodyMedium.copyWith(
                    color: context.secondary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(widget.transaction.status),
                  style: context.titleMedium.copyWith(
                    color: _getStatusColor(widget.transaction.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Adicional',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: context.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.secondary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            spacing: 16,
            children: [
              _buildInfoRow(
                'Origen',
                widget.transaction.origin,
                HugeIcons.strokeRoundedLocation01,
              ),
              _buildInfoRow(
                'Destino',
                widget.transaction.destination,
                HugeIcons.strokeRoundedLocation05,
              ),
              _buildInfoRow(
                'Fecha de Creación',
                Utils.formatDate(widget.transaction.createdAt),
                HugeIcons.strokeRoundedCalendar03,
              ),
              _buildInfoRow(
                'Creado por',
                'Usuario ID: ${widget.transaction.createdBy}',
                HugeIcons.strokeRoundedUser,
              ),
              if (widget.transaction.approvedBy != null)
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      context.read<UserBloc>().add(GetUserByIdRequested(widget.transaction.approvedBy!));
                      return _buildInfoRow(
                        'Aprobado por',
                        'Usuario ID: ${state.user.name}',
                        HugeIcons.strokeRoundedTick01,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              if (widget.transaction.rejectedBy != null)
                _buildInfoRow(
                  'Rechazado por',
                  'Usuario ID: ${widget.transaction.rejectedBy}',
                  HugeIcons.strokeRoundedCancel01,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: context.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.bodySmall.copyWith(
                  color: context.secondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.bodyMedium.copyWith(
                  color: context.secondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TransactionState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        UserEntity? currentUser;
        if (authState is AuthAuthenticated) {
          currentUser = authState.user;
        }

        // Solo usuarios admin y root pueden cambiar el estado
        final canUpdateStatus = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.root;

        // Solo mostrar botones de acción si puede actualizar y el estado es pendiente
        final showActionButtons = canUpdateStatus && widget.transaction.status == StatusTransaction.pending;

        if (context.isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showActionButtons) ...[
                SizedBox(
                  height: _getButtonHeight(context),
                  child: CustomButton(
                    label: 'Aprobar Transacción',
                    isLoading: _isLoading(state),
                    onTap: () => _updateTransactionStatus(StatusTransaction.approved),
                    leading: _isLoading(state) 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: _approvedColor.contrast),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: _getButtonHeight(context),
                  child: CustomButton(
                    label: 'Rechazar Transacción',
                    isLoading: _isLoading(state),
                    onTap: () => _updateTransactionStatus(StatusTransaction.rejected),
                    leading: Icon(HugeIcons.strokeRoundedCancel01, color: _rejectedColor.contrast),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: _getButtonHeight(context),
                child: CustomButton(
                  label: 'Cerrar',
                  outline: true,
                  isLoading: _isLoading(state),
                  onTap: () => context.pop(),
                ),
              ),
            ],
          );
        } else {
          // En tablet/desktop, botones en fila
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: _getButtonHeight(context),
                  child: CustomButton(
                    label: 'Cerrar',
                    outline: true,
                    isLoading: _isLoading(state),
                    onTap: () => context.pop(),
                  ),
                ),
              ),
              if (showActionButtons) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: _getButtonHeight(context),
                    child: CustomButton(
                      label: 'Rechazar',
                      color: _rejectedColor,
                      isLoading: _isLoading(state),
                      leading: Icon(HugeIcons.strokeRoundedCancel01, color: _rejectedColor.contrast),
                      onTap: () => _updateTransactionStatus(StatusTransaction.rejected),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: _getButtonHeight(context),
                    child: CustomButton(
                      label: 'Aprobar',
                      isLoading: _isLoading(state),
                      color: _approvedColor,
                      onTap: () => _updateTransactionStatus(StatusTransaction.approved),
                      leading: _isLoading(state) 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: _approvedColor.contrast),
                    ),
                  ),
                ),
              ],
            ],
          );
        }
      },
    );
  }

  // ===================== MÉTODOS AUXILIARES =====================

  bool _isLoading(TransactionState state) {
    return state is TransactionLoading;
  }

  void _updateTransactionStatus(StatusTransaction newStatus) {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              newStatus == StatusTransaction.approved 
                  ? HugeIcons.strokeRoundedCheckmarkCircle02 
                  : HugeIcons.strokeRoundedCancel01,
              color: newStatus == StatusTransaction.approved 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFEF4444),
            ),
            const SizedBox(width: 12),
            Text(
              '${newStatus == StatusTransaction.approved ? "Aprobar" : "Rechazar"} Transacción',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Está seguro que desea ${newStatus == StatusTransaction.approved ? "aprobar" : "rechazar"} esta transacción? Esta acción no se puede deshacer.',
          style: context.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: context.bodyMedium.copyWith(
                color: context.secondary.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              
              final updatedTransaction = TransactionEntity(
                id: widget.transaction.id,
                title: widget.transaction.title,
                concept: widget.transaction.concept,
                amount: widget.transaction.amount,
                origin: widget.transaction.origin,
                destination: widget.transaction.destination,
                createdBy: widget.transaction.createdBy,
                status: newStatus,
                createdAt: widget.transaction.createdAt,
              );
              
              context.read<TransactionBloc>().add(
                UpdateTransactionRequested(
                  widget.transaction.id!,
                  updatedTransaction,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == StatusTransaction.approved 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(newStatus == StatusTransaction.approved ? 'Aprobar' : 'Rechazar'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StatusTransaction status) {
    return switch (status) {
      StatusTransaction.pending => const Color(0xFFF59E0B),
      StatusTransaction.approved => const Color(0xFF10B981),
      StatusTransaction.rejected => const Color(0xFFEF4444),
    };
  }

  String _getStatusText(StatusTransaction status) {
    return switch (status) {
      StatusTransaction.pending => 'Pendiente',
      StatusTransaction.approved => 'Aprobada',
      StatusTransaction.rejected => 'Rechazada',
    };
  }

  IconData _getStatusIcon(StatusTransaction status) {
    return switch (status) {
      StatusTransaction.pending => HugeIcons.strokeRoundedClock01,
      StatusTransaction.approved => HugeIcons.strokeRoundedCheckmarkCircle02,
      StatusTransaction.rejected => HugeIcons.strokeRoundedCancel01,
    };
  }

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(context.isMobile ? 16 : 20),
      ),
    );
  }
}