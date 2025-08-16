import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'package:manage_transaction_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:manage_transaction_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:manage_transaction_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['URL_DATABASE']!,
    anonKey: dotenv.env['API_KEY']!,
  );

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerFactory(() => AuthBloc(sl()));
}