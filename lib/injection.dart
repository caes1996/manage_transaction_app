import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:manage_transaction_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:manage_transaction_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:manage_transaction_app/features/auth/domain/repositories/user_repository.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/user/user_bloc.dart';
import 'package:manage_transaction_app/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:manage_transaction_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:manage_transaction_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'package:manage_transaction_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:manage_transaction_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:manage_transaction_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['URL_DATABASE']!,
    anonKey: dotenv.env['API_KEY']!,
  );

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource(sl()));
  sl.registerLazySingleton<TransactionRemoteDataSource>(() => TransactionRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => UserBloc(sl()));
  sl.registerFactory(() => TransactionBloc(sl()));
}