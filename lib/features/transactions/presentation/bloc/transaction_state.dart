import 'package:equatable/equatable.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final TransactionEntity transaction;
  TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionCreated extends TransactionState {
  final TransactionEntity transaction;
  TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionState {
  final TransactionEntity transaction;
  TransactionUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionState {
  final int id;
  TransactionDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}