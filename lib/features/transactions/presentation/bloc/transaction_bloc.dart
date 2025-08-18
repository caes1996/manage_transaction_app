
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  TransactionBloc(this.transactionRepository) : super(TransactionLoading()) {

    on<CreateTransactionRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await transactionRepository.createTransaction(event.transaction);
        emit(TransactionCreated(event.transaction));
      } catch (e) {
        emit(TransactionError('No se pudo crear la transacción. Error: $e'));
      }
    });

    on<UpdateTransactionRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await transactionRepository.updateTransaction(event.id, event.transaction);
        emit(TransactionUpdated(event.transaction));
      } catch (e) {
        emit(TransactionError('No se pudo actualizar la transacción. Error: $e'));
      }
    });

    on<DeleteTransactionRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await transactionRepository.deleteTransaction(event.id);
        emit(TransactionDeleted(event.id));
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
        final transactions = await transactionRepository.getTransactions(
          orderBy: event.orderBy,
          ascending: event.ascending,
          status: event.status,
          userId: event.userId,
          limit: event.limit,
          offset: event.offset,
        );
        emit(TransactionsLoaded(transactions));
      } catch (e) {
        emit(TransactionError('No se pudo obtener las transacciones. Error: $e'));
      }
    });
  }
}