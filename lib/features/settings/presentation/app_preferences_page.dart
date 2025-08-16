import 'package:flutter/material.dart';

class AppPreferencesPage extends StatelessWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // aquí: tema, idioma, notificaciones, accesibilidad, etc.
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias de la app')),
      body: const Center(child: Text('Contenido de Preferencias (global)')),
    );
  }
}
