import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_event.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_state.dart';

class UsersPageStub extends StatefulWidget {
  const UsersPageStub({super.key});
  @override
  State<UsersPageStub> createState() => _UsersPageStubState();
}

class _UsersPageStubState extends State<UsersPageStub> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetAllUsersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UsersLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Usuarios')),
            body: ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            ),
          );
        }
        if (state is UserLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Usuarios')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is UserError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Usuarios')),
            body: Center(child: Text(state.message)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Usuarios')),
          body: Center(child: Text('Módulo de Usuarios (stub)')),
        );
      },
    );
  }
}
