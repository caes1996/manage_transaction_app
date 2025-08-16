import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // aquí pondrás: perfil, cambio de contraseña, 2FA, sesiones, etc.
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y seguridad')),
      body: const Center(child: Text('Contenido de Perfil y seguridad (OUT)')),
    );
  }
}
