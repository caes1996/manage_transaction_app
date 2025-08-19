import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  bool _isSignUpMode = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
    emailCtrl.clear();
    passCtrl.clear();
    nameCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthError,
      listener: (context, state) {
        final msg = (state as AuthError).message;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Scaffold(
        body: SafeArea(
          child: context.isMobile
            ? _contentMobile()
            : context.isTablet
              ? _contentTablet()
              : _contentDesktop(),
        ),
      ),
    );
  }

  Widget _contentDesktop() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primary,
                    context.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.onPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedUserAccount,
                        size: 120,
                        color: context.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Manage Transaction App',
                      style: context.titleLarge.copyWith(
                        color: context.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Inicia sesión o crea una cuenta para continuar',
                      style: context.bodyMedium.copyWith(
                        color: context.onPrimary.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: context.surface,
              child: _buildSimpleCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentTablet() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.primary,
                  context.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.onPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedUserAccount,
                      size: 80,
                      color: context.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Manage Transaction App',
                    style: context.titleLarge.copyWith(
                      color: context.onPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Inicia sesión o crea una cuenta para continuar',
                    style: context.bodyMedium.copyWith(
                      color: context.onPrimary.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: _buildSimpleCard(),
          ),
        ],
      ),
    );
  }

  Widget _contentMobile() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedUserAccount,
                size: 56,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Manage Transaction App',
              style: context.titleLarge.copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenido de vuelta',
              style: context.bodyMedium.copyWith(
                color: context.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            _buildSimpleCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey(_isSignUpMode),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _isSignUpMode ? _buildSignUpForm() : _buildSignInForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!context.isMobile) ...[
          Text(
            'Iniciar Sesión',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus credenciales para acceder',
            style: context.bodyMedium.copyWith(
              color: context.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        _buildEmailInput(),
        _buildPasswordInput(),
        const SizedBox(height: 24),
        _buildButtonSignIn(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: context.onSurface.withValues(alpha: 0.5))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: context.bodySmall.copyWith(
                  color: context.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: context.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 16),
        _buildButtonSignUp(),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!context.isMobile) ...[
          Text(
            'Crear Cuenta',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Completa tus datos para registrarte',
            style: context.bodyMedium.copyWith(
              color: context.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        _buildNameInput(),
        _buildEmailInput(),
        _buildPasswordInput(),
        const SizedBox(height: 24),
        _buildButtonCreateAccount(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: context.onSurface.withValues(alpha: 0.5))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: context.bodySmall.copyWith(
                  color: context.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: context.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 16),
        _buildButtonBackToSignIn(),
      ],
    );
  }

  Widget _buildEmailInput() {
    return CustomInputText(
      hint: 'Correo electrónico',
      controller: emailCtrl,
      prefixIcon: Icon(
        HugeIcons.strokeRoundedMail02,
        color: context.primary.withValues(alpha: 0.7),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordInput() {
    return CustomInputText(
      hint: 'Contraseña',
      controller: passCtrl,
      prefixIcon: Icon(
        HugeIcons.strokeRoundedLockPassword,
        color: context.primary.withValues(alpha: 0.7),
      ),
      obscureText: true,
    );
  }

  Widget _buildNameInput() {
    return CustomInputText(
      hint: 'Nombre completo',
      controller: nameCtrl,
      prefixIcon: Icon(
        HugeIcons.strokeRoundedUserAccount,
        color: context.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildButtonSignIn() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return CustomButton(
          label: 'Iniciar Sesión',
          onTap: _signIn,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildButtonCreateAccount() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return CustomButton(
          label: 'Crear Cuenta',
          onTap: _createAccount,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildButtonSignUp() {
    return CustomButton(
      onTap: _toggleMode,
      label: 'Crear cuenta',
      outline: true,
    );
  }

  Widget _buildButtonBackToSignIn() {
    return CustomButton(
      onTap: _toggleMode,
      label: 'Ya tengo cuenta',
      outline: true,
    );
  }

  void _signIn() {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (!email.isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo inválido')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(SignInRequested(email, password));
  }

  void _createAccount() {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final emailOk = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo inválido')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(SignUpRequested(email, password, name, UserRole.root));
  }

}