import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionsPageStub extends StatefulWidget {
  const TransactionsPageStub({super.key});
  @override
  State<TransactionsPageStub> createState() => _TransactionsPageStubState();
}

class _TransactionsPageStubState extends State<TransactionsPageStub> {
  @override
  void initState() {
    super.initState();
    // Evita leer el bloc demasiado pronto durante el initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(GetTransactionsRequested());
    });
  }

  void _createDemoTx() {
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated) {
    final userId = authState.user.id; // tu UserEntity.id

    context.read<TransactionBloc>().add(
      CreateTransactionRequested(
        TransactionEntity(
          id: 0,
          title: 'title',
          concept: 'concept',
          amount: 100,
          origin: 'origin',
          destination: 'destination',
          createdBy: userId,
          status: StatusTransaction.pending,
          createdAt: DateTime.now(),
        ),
      ),
    );
  } else {
    // Opcional: manejar caso no logueado
    print('No hay usuario autenticado');
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionsLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Transacciones'),
              actions: [
                IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedSettings04),
                  onPressed: () => context.go(AppRoutes.settingsSection('transactions')),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(transaction.concept),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _createDemoTx,
              child: const Icon(HugeIcons.strokeRoundedPlusSign),
            ),
          );
        }

        if (state is TransactionLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Transacciones')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TransactionError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Transacciones')),
            body: Center(child: Text(state.message)),
          );
        }

        // Estado inicial u otros no contemplados
        return Scaffold(
          appBar: AppBar(title: const Text('Transacciones')),
          body: const Center(child: Text('Módulo de Transacciones (stub)')),
          floatingActionButton: FloatingActionButton(
            onPressed: _createDemoTx,
            child: const Icon(HugeIcons.strokeRoundedPlusSign),
          ),
        );
      },
    );
  }
}
