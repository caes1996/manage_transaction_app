import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manage_transaction_app/features/transactions/data/models/transaction_model.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionRemoteDataSource {
  final SupabaseClient client;
  TransactionRemoteDataSource(this.client);

  final String _schema = dotenv.env['DB_SCHEMA']!;
  final String _tableName = 'transactions';

  PostgrestQueryBuilder get _table => client.schema(_schema).from(_tableName);

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final row = await _table.insert(transaction.toDbInsert()).select().single();
    return TransactionModel.fromDb(row);
  }

  Future<TransactionModel> updateTransaction(int id, TransactionModel transaction) async {
    final row = await _table.update(transaction.toDbUpdate()).eq('id', id).select().single();
    return TransactionModel.fromDb(row);
  }

  Future<TransactionModel> deleteTransaction(int id) async {
    final row = await _table.delete().eq('id', id).select().single();
    return TransactionModel.fromDb(row);
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final row = await _table.select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return TransactionModel.fromDb(row);
  }

  Future<List<TransactionModel>> getTransactions() async {
  final query = await _table.select();
  return query.map((row) => TransactionModel.fromDb(row)).toList();
}

  Stream<List<TransactionModel>> listenTransactions({
    String? createdBy,
    StatusTransaction? status,
  }) {
    final qb = client.schema(_schema).from(_tableName);
    final baseStream = qb.stream(primaryKey: ['id']);

    return baseStream.map((rows) {
      final filtered = rows
          .where((r) => createdBy == null || r['created_by'] == createdBy)
          .where((r) => status == null || r['status'] == status.name);
      return filtered.map((r) => TransactionModel.fromDb(r)).toList();
    });
  }

  Stream<List<TransactionModel>> streamTransactions() {
    return client.schema(_schema)
      .from(_tableName)
      .stream(primaryKey: ['id'])
      .map((rows) => rows.map(TransactionModel.fromDb)
      .toList());
  }
}