import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(int id, TransactionEntity transaction);
  Future<void> deleteTransaction(int id);
  Future<TransactionEntity?> getTransactionById(int id);
  Future<List<TransactionEntity>> getTransactions();
  Stream<List<TransactionEntity>> watchTransactions();
}
