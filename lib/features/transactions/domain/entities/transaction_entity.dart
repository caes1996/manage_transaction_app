import 'package:equatable/equatable.dart';

enum StatusTransaction { pending, approved, rejected }

class TransactionEntity extends Equatable {
  final int? id;
  final String title;
  final String concept;
  final double amount;
  final String origin;
  final String destination;
  final String createdBy;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final StatusTransaction status;

  const TransactionEntity({
    this.id,
    required this.title,
    required this.concept,
    required this.amount,
    required this.origin,
    required this.destination,
    required this.createdBy,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    concept,
    amount,
    origin,
    destination,
    createdBy,
    createdAt,
    approvedBy,
    approvedAt,
    rejectedBy,
    rejectedAt,
    status,
  ];
}