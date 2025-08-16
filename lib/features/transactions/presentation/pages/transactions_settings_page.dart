import 'package:flutter/material.dart';

class TransactionsSettingsPage extends StatelessWidget {
  const TransactionsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // aquí: políticas, formatos, límites, columnas visibles, etc.
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de transacciones')),
      body: const Center(child: Text('Contenido de Ajustes de Transacciones')),
    );
  }
}