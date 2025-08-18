import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:manage_transaction_app/main.dart';
import 'package:manage_transaction_app/injection.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth/auth_event.dart';

class SchemaScope extends InheritedWidget {
  final SchemaController schemaController;
  const SchemaScope({super.key, required this.schemaController, required super.child});

  static SchemaController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SchemaScope>();
    assert(scope != null, 'No SchemaScope found in the widget tree');
    return scope!.schemaController;
  }

  @override
  bool updateShouldNotify(covariant SchemaScope oldWidget) =>
      schemaController != oldWidget.schemaController;
}

class ManageTransactionApp extends StatelessWidget {
  const ManageTransactionApp({super.key, required this.schemaController});
  final SchemaController schemaController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()
            ..add(AuthStarted()),
        ),
        BlocProvider<UserBloc>(
          create: (_) => sl<UserBloc>()
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>()
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final router = AppRouter.create(authBloc);

          return SchemaScope(
            schemaController: schemaController,
            child: MaterialApp.router(
              title: 'Manage Transaction App',
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
