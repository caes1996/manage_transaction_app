import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';

class TransactionsPageStub extends StatelessWidget {
  const TransactionsPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones'), actions: [
        IconButton(
          icon: const Icon(HugeIcons.strokeRoundedSettings04),
          onPressed: () => context.go(AppRoutes.settingsSection('transactions')),
        )
      ]),
      body: const Center(child: Text('Módulo de Transacciones (stub)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(HugeIcons.strokeRoundedPlusSign),
      ),
    );
  }
}
