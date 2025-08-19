import 'package:equatable/equatable.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final TransactionEntity transaction;
  TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionCreated extends TransactionState {
  final String message;
  final bool shouldCloseModal;
  TransactionCreated(this.message, {this.shouldCloseModal = true});

  @override
  List<Object?> get props => [message, shouldCloseModal];
}

class TransactionUpdated extends TransactionState {
  final String message;
  final bool shouldCloseModal;
  TransactionUpdated(this.message, {this.shouldCloseModal = true});

  @override
  List<Object?> get props => [message, shouldCloseModal];
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionOperationLoading extends TransactionState {
  final String operation;
  TransactionOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}