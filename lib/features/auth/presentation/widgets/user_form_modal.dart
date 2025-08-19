import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_state.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';

class UserFormModal extends StatefulWidget {
  const UserFormModal({super.key});

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  UserRole? _role;

  // Variables responsivas según el contexto
  double _getModalWidth(BuildContext context) {
    if (context.isMobile) return MediaQuery.of(context).size.width * 0.95;
    if (context.isTablet) return 500.0;
    return 450.0; // Desktop
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
          maxWidth: context.isMobile ? double.infinity : 500,
        ),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(context.isMobile ? 12.0 : 16.0),
          boxShadow: [
            BoxShadow(
              color: context.error.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserCreated) {
              _showSnackBar(context, state.message, Colors.green, Icons.check_circle);
              // Cerrar el modal después de un breve delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.pop();
                }
              });
            } else if (state is UserError) {
              _showSnackBar(
                context,
                state.message,
                Colors.red,
                Icons.error,
              );
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
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
                      _buildNameField(context, state),
                      _buildEmailField(context, state),
                      _buildPasswordField(context, state),
                      _buildRoleField(context, state),
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

  Widget _buildHeader(BuildContext context, UserState state) {
    return Column(
      children: [
        // Icono de cierre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40), // Espaciado
            Text(
              'Registro de Usuario',
              style: TextStyle(
                fontSize: _getTitleSize(context),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
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
            'Complete los datos para crear su cuenta',
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

  Widget _buildNameField(BuildContext context, UserState state) {
    return CustomInputTextForm(
      hint: 'Nombre Completo',
      prefixIcon: const Icon(HugeIcons.strokeRoundedUser),
      textValidator: 'El nombre es requerido',
      textCapitalization: TextCapitalization.words,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 2,
          errorMessage: 'El nombre debe tener al menos 2 caracteres',
        )
      ],
      onSaved: (value) => _name = value!,
    );
  }

  Widget _buildEmailField(BuildContext context, UserState state) {
    return CustomInputTextForm(
      hint: 'Correo electrónico',
      prefixIcon: const Icon(HugeIcons.strokeRoundedMail01),
      keyboardType: TextInputType.emailAddress,
      textValidator: 'El email es requerido',
      validationRules: [
        ValidationRule(
          condition: (value) => (value!.isValidEmail),
          errorMessage: 'Ingrese un email válido',
        )
      ],
      onSaved: (value) => _email = value!,
    );
  }

  Widget _buildPasswordField(BuildContext context, UserState state) {
    return CustomInputTextForm(
      hint: 'Contraseña',
      prefixIcon: const Icon(HugeIcons.strokeRoundedLock),
      textValidator: 'La contraseña es requerida',
      obscureText: true,
      validationRules: [
        ValidationRule(
          condition: (value) => value!.length >= 6,
          errorMessage: 'La contraseña debe tener al menos 6 caracteres',
        )
      ],
      onSaved: (value) => _password = value!,
    );
  }

  Widget _buildRoleField(BuildContext context, UserState state) {
    return CustomDropdownInput<UserRole>(
      hint: 'Rol',
      selectedValue: _role,
      prefixIcon: const Icon(HugeIcons.strokeRoundedUser),
      isRequired: true,
      enabled: !_isLoading(state),
      onChanged: (value) => setState(() => _role = value!),
      items: UserRole.values.where((role) => role != UserRole.root)
        .map((role) => DropdownData<UserRole>(
          value: role,
          displayText: role.name.capitalize,
        )).toList(),
    );
  }

  Widget _buildButtons(BuildContext context, UserState state) {
    final isLoading = _isLoading(state);
    
    if (context.isMobile) {
      // En móvil, botones apilados verticalmente
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _getButtonHeight(context),
            child: CustomButton(
              label: 'Registrar',
              isDisabled: isLoading,
              isLoading: isLoading,
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
                label: 'Registrar',
                isDisabled: isLoading,
                isLoading: isLoading,
                onTap: () => _submitForm(context),
              ),
            ),
          ),
        ],
      );
    }
  }

  // Método auxiliar para verificar si está cargando
  bool _isLoading(UserState state) {
    return state is UserLoading || state is UserOperationLoading;
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate() && _role != null) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();
      
      // CAMBIO PRINCIPAL: Usar UserBloc en lugar de AuthBloc
      final user = UserEntity(
        id: '', // Se generará automáticamente
        name: _name,
        email: _email,
        role: _role!,
        createdAt: DateTime.now()
      );
      
      context.read<UserBloc>().add(
        CreateUserRequested(user, _password),
      );
      
      // NO llamar context.pop() aquí - el BlocListener se encargará
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

// ModalHelper corregido
class ModalHelper {
  static Future<void> showUserFormModal(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        // CAMBIO IMPORTANTE: Pasar el UserBloc al modal
        return BlocProvider<UserBloc>.value(
          value: context.read<UserBloc>(),
          child: const UserFormModal(),
        );
      },
    );
  }
}