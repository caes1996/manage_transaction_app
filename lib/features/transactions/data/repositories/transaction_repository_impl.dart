import 'package:manage_transaction_app/features/transactions/data/models/transaction_model.dart';

import '../datasources/transaction_remote_data_source.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remote;
  TransactionRepositoryImpl(this.remote);

  @override
  Future<void> createTransaction(TransactionEntity transaction) {
    final model = TransactionModel.fromEntity(transaction);
    return remote.createTransaction(model);
  }

  @override
  Future<void> updateTransaction(int id, TransactionEntity transaction) {
    final model = TransactionModel.fromEntity(transaction);
    return remote.updateTransaction(id, model);
  }

  @override
  Future<void> deleteTransaction(int id) => remote.deleteTransaction(id);

  @override
  Future<TransactionEntity?> getTransactionById(int id) => remote.getTransactionById(id);

  @override
  Future<List<TransactionEntity>> getTransactions() => remote.getTransactions();

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return remote.streamTransactions().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}