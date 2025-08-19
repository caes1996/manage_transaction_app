
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:manage_transaction_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  StreamSubscription<List<TransactionEntity>>? _transactionsSub;
  
  TransactionBloc(this.transactionRepository) : super(TransactionLoading()) {

    on<CreateTransactionRequested>((event, emit) async {
      emit(TransactionOperationLoading('creating'));
      try {
        await transactionRepository.createTransaction(event.transaction);
        emit(TransactionCreated('Transacción creada correctamente'));
      } catch (e) {
        emit(TransactionError('No se pudo crear la transacción. Error: $e'));
      }
    });

    on<UpdateTransactionRequested>((event, emit) async {
      emit(TransactionOperationLoading('updating'));
      try {
        await transactionRepository.updateTransaction(event.id, event.transaction);
        emit(TransactionUpdated('Transacción actualizada correctamente'));
      } catch (e) {
        emit(TransactionError('No se pudo actualizar la transacción. Error: $e'));
      }
    });

    on<DeleteTransactionRequested>((event, emit) async {
      emit(TransactionOperationLoading('deleting'));
      try {
        await transactionRepository.deleteTransaction(event.id);
        emit(TransactionDeleted('Transacción eliminada correctamente'));
      } catch (e) {
        emit(TransactionError('No se pudo eliminar la transacción. Error: $e'));
      }
    });

    on<GetTransactionByIdRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transaction = await transactionRepository.getTransactionById(event.id);
        if (transaction == null) {
          emit(TransactionError('No se pudo obtener la transacción.'));
          return;
        }
        emit(TransactionLoaded(transaction));
      } catch (e) {
        emit(TransactionError('No se pudo obtener la transacción. Error: $e'));
      }
    });

    on<GetTransactionsRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await transactionRepository.getTransactions();
        emit(TransactionsLoaded(transactions));
      } catch (e) {
        emit(TransactionError('No se pudo obtener las transacciones. Error: $e'));
      }
    });

    on<TransactionsWatchRequested>((event, emit) async {
      if (_transactionsSub != null) return;
      emit(TransactionLoading());
      _transactionsSub = transactionRepository.watchTransactions().listen(
        (transactions) => add(TransactionsStreamEmitted(transactions)),
        onError: (e) {
          emit(TransactionError('Error en tiempo real: $e'));
        },
      );
    });

    on<TransactionsStreamEmitted>((event, emit) async {
      emit(TransactionsLoaded(event.transactions));
    });

    on<TransactionsStopWatching>((event, emit) async {
      await _transactionsSub?.cancel();
      _transactionsSub = null;
    });
  }

  @override
  Future<void> close() async {
    await _transactionsSub?.cancel();
    return super.close();
  }
}