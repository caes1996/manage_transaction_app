
import 'package:equatable/equatable.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateTransactionRequested extends TransactionEvent {
  final TransactionEntity transaction;
  CreateTransactionRequested(this.transaction);
}

class UpdateTransactionRequested extends TransactionEvent {
  final int id;
  final TransactionEntity transaction;
  UpdateTransactionRequested(this.id, this.transaction);
}

class DeleteTransactionRequested extends TransactionEvent {
  final int id;
  DeleteTransactionRequested(this.id);
}

class GetTransactionByIdRequested extends TransactionEvent {
  final int id;
  GetTransactionByIdRequested(this.id);
}

class GetTransactionsRequested extends TransactionEvent {
  final String orderBy;
  final bool ascending;
  final StatusTransaction? status;
  final String? userId;
  final int? limit;
  final int? offset;
  GetTransactionsRequested({
    this.orderBy = 'created_at',
    this.ascending = false,
    this.status,
    this.userId,
    this.limit,
    this.offset,
  });
}

