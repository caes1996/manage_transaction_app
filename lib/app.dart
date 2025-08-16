import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/core/constants/app_routes.dart';
import 'package:manage_transaction_app/main.dart';
import 'package:manage_transaction_app/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

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
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: SchemaScope(
        schemaController: schemaController,
        child: MaterialApp.router(
          title: 'Manage Transaction App',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.instance.router,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
