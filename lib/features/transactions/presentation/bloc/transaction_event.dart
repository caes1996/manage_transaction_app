
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

class GetTransactionsRequested extends TransactionEvent {
  GetTransactionsRequested();
}

class TransactionsWatchRequested extends TransactionEvent {}

class TransactionsStopWatching extends TransactionEvent {}

class TransactionsStreamEmitted extends TransactionEvent {
  final List<TransactionEntity> transactions;
  TransactionsStreamEmitted(this.transactions);

  @override
  List<Object?> get props => [transactions];
}