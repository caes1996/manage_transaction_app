import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa el AuthBloc ya creado en ManageTransactionApp
    // y NO navegues desde aquí; solo muestra loading.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}