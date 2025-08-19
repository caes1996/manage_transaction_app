import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';

class TransactionFormModal extends StatefulWidget {
  const TransactionFormModal({super.key});

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  String _concept = '';
  double _amount = 0.0;
  String _origin = '';
  String _destination = '';

  // Variables responsivas según el contexto
  double _getModalWidth(BuildContext context) {
    if (context.isMobile) return MediaQuery.of(context).size.width * 0.95;
    if (context.isTablet) return 600.0;
    return 550.0; // Desktop
  }

  EdgeInsets _getModalPadding(BuildContext context) {
    if (context.isMobile) return const EdgeInsets.all(16.0);
    if (context.isTablet) return const EdgeInsets.all(24.0);
    return const EdgeInsets.all(32.0); // Desktop
  }

  double _getFieldSpacing(BuildContext context) {
    if (context.isMobile) return 12.0;
    if (context.isTablet) return 16.0;
    return 20.0; // Desktop
  }

  double _getTitleSize(BuildContext context) {
    if (context.isMobile) return 20.0;
    if (context.isTablet) return 22.0;
    return 24.0; // Desktop
  }

  double _getButtonHeight(BuildContext context) {
    if (context.isMobile) return 45.0;
    if (context.isTablet) return 48.0;
    return 52.0; // Desktop
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 16.0 : 40.0,
        vertical: context.isMobile ? 24.0 : 40.0,
      ),
      child: Container(
        width: _getModalWidth(context),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: context.isMobile ? double.infinity : 600,
        ),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(context.isMobile ? 12.0 : 16.0),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionCreated) {
              _showSnackBar(
                context,
                'Transacción creada exitosamente',
                Colors.green,
                Icons.check_circle,
              );
              // Cerrar el modal después de un breve delay
              Future.delayed(const Duration(milliseconds: 500), () {
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
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: _getModalPadding(context),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, state),
                      SizedBox(height: _getFieldSpacing(context)),
                      _buildTitleField(context, state),
                      _buildConceptField(context, state),
                      _buildAmountField(context, state),
                      _buildOriginField(context, state),
                      _buildDestinationField(context, state),
                      SizedBox(height: _getFieldSpacing(context) * 1.5),
                      _buildButtons(context, state),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransactionState state) {
    return Column(
      children: [
        // Header con título y botón de cierre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40), // Espaciado
            Expanded(
              child: Text(
                'Nueva Transacción',
                style: TextStyle(
                  fontSize: _getTitleSize(context),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: _isLoading(state) ? null : () => context.pop(),
              icon: Icon(
                Icons.close,
                size: context.isMobile ? 20 : 24,
                color: _isLoading(state) 
                    ? Colors.grey 
                    : Theme.of(context).iconTheme.color,
              ),
              splashRadius: 20,
            ),
          ],
        ),
        if (context.isDesktop || context.isTablet) ...[
          const SizedBox(height: 8),
          Text(
            'Complete los datos para crear una nueva transacción',
            style: TextStyle(
              fontSize: context.isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTitleField(BuildContext context, TransactionState state) {
    return CustomInputTextForm(
      hint: 'Título de la transacción',
      prefixIcon: const Icon(HugeIcons.strokeRoundedFile02),
      textValidator: 'El título es requerido',
      textCapitalization: TextCapitalization.sentences,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 3,
          errorMessage: 'El título debe tener al menos 3 caracteres',
        )
      ],
      onSaved: (value) => _title = value!,
    );
  }

  Widget _buildConceptField(BuildContext context, TransactionState state) {
    return CustomInputTextForm(
      hint: 'Concepto o descripción',
      prefixIcon: const Icon(HugeIcons.strokeRoundedNote),
      textValidator: 'El concepto es requerido',
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 5,
          errorMessage: 'El concepto debe tener al menos 5 caracteres',
        )
      ],
      onSaved: (value) => _concept = value!,
    );
  }

  Widget _buildAmountField(BuildContext context, TransactionState state) {
    return CustomInputTextForm(
      hint: 'Monto',
      prefixIcon: const Icon(HugeIcons.strokeRoundedDollarCircle),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textValidator: 'El monto es requerido',
      validationRules: [
        ValidationRule(
          condition: (value) {
            final amount = double.tryParse(value!) ?? 0;
            return amount > 0;
          },
          errorMessage: 'El monto debe ser mayor a 0',
        ),
        ValidationRule(
          condition: (value) {
            final amount = double.tryParse(value!) ?? 0;
            return amount <= 1000000;
          },
          errorMessage: 'El monto no puede exceder 1,000,000',
        )
      ],
      onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
    );
  }

  Widget _buildOriginField(BuildContext context, TransactionState state) {
    return CustomInputTextForm(
      hint: 'Origen de la transacción',
      prefixIcon: const Icon(HugeIcons.strokeRoundedLocation03),
      textValidator: 'El origen es requerido',
      textCapitalization: TextCapitalization.words,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 2,
          errorMessage: 'El origen debe tener al menos 2 caracteres',
        )
      ],
      onSaved: (value) => _origin = value!,
    );
  }

  Widget _buildDestinationField(BuildContext context, TransactionState state) {
    return CustomInputTextForm(
      hint: 'Destino de la transacción',
      prefixIcon: const Icon(HugeIcons.strokeRoundedLocation09),
      textValidator: 'El destino es requerido',
      textCapitalization: TextCapitalization.words,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 2,
          errorMessage: 'El destino debe tener al menos 2 caracteres',
        )
      ],
      onSaved: (value) => _destination = value!,
    );
  }

  Widget _buildButtons(BuildContext context, TransactionState state) {
    final isLoading = _isLoading(state);
    
    if (context.isMobile) {
      // En móvil, botones apilados verticalmente
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _getButtonHeight(context),
            child: CustomButton(
              label: 'Crear Transacción',
              isDisabled: isLoading,
              isLoading: isLoading,
              leading: Icon(HugeIcons.strokeRoundedAdd01, color: context.onPrimary),
              onTap: () => _submitForm(context),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _getButtonHeight(context),
            child: CustomButton(
              label: 'Cancelar',
              isDisabled: isLoading,
              outline: true,
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
                label: 'Cancelar',
                isDisabled: isLoading,
                outline: true,
                onTap: () => context.pop(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: _getButtonHeight(context),
              child: CustomButton(
                label: 'Crear Transacción',
                isDisabled: isLoading,
                isLoading: isLoading,
                leading: const Icon(HugeIcons.strokeRoundedAdd01),
                onTap: () => _submitForm(context),
              ),
            ),
          ),
        ],
      );
    }
  }

  // Método auxiliar para verificar si está cargando
  bool _isLoading(TransactionState state) {
    return state is TransactionLoading;
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();
      
      // Obtener el usuario actual autenticado
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final userId = authState.user.id;
        
        final transaction = TransactionEntity(
          id: 0, // Se generará automáticamente en el backend
          title: _title,
          concept: _concept,
          amount: _amount,
          origin: _origin,
          destination: _destination,
          createdBy: userId,
          status: StatusTransaction.pending, // Nueva transacción siempre es pendiente
          createdAt: DateTime.now(),
        );
        
        context.read<TransactionBloc>().add(
          CreateTransactionRequested(transaction),
        );
      } else {
        _showSnackBar(
          context,
          'Error: Usuario no autenticado',
          Colors.red,
          Icons.error,
        );
      }
    }
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