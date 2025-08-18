import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.concept,
    required super.amount,
    required super.origin,
    required super.destination,
    required super.createdBy,
    required super.createdAt,
    required super.approvedBy,
    required super.approvedAt,
    required super.rejectedBy,
    required super.rejectedAt,
    required super.status,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.parse(v.toString());
  }

  static StatusTransaction _parseStatus(dynamic v) {
    final s = (v ?? '').toString();
    switch (s) {
      case 'pending': return StatusTransaction.pending;
      case 'approved': return StatusTransaction.approved;
      case 'rejected': return StatusTransaction.rejected;
      default: return StatusTransaction.pending;
    }
  }

  factory TransactionModel.fromDb(Map<String, dynamic> map) {
    return TransactionModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      concept: map['concept'] as String,
      amount: _toDouble(map['amount']),
      origin: map['origin'] as String,
      destination: map['destination'] as String,
      createdBy: map['created_by'] as String,
      createdAt: _parseDate(map['created_at'])!,
      approvedBy: map['approved_by'] as String?,
      approvedAt: _parseDate(map['approved_at']),
      rejectedBy: map['rejected_by'] as String?,
      rejectedAt: _parseDate(map['rejected_at']),
      status: _parseStatus(map['status']),
    );
  }

  Map<String, dynamic> toDbInsert() => {
    'title': title,
    'concept': concept,
    'amount': amount,
    'origin': origin,
    'destination': destination,
    'created_by': createdBy,
    'status': status.name,
  };

  Map<String, dynamic> toDbUpdate() => {
    'title': title,
    'concept': concept,
    'amount': amount,
    'origin': origin,
    'destination': destination,
    'status': status.name,
    'approved_by': approvedBy,
    'approved_at': approvedAt?.toIso8601String(),
    'rejected_by': rejectedBy,
    'rejected_at': rejectedAt?.toIso8601String(),
  }..removeWhere((k, v) => v == null);

  factory TransactionModel.fromEntity(TransactionEntity e) => TransactionModel(
    id: e.id,
    title: e.title,
    concept: e.concept,
    amount: e.amount,
    origin: e.origin,
    destination: e.destination,
    createdBy: e.createdBy,
    createdAt: e.createdAt,
    approvedBy: e.approvedBy,
    approvedAt: e.approvedAt,
    rejectedBy: e.rejectedBy,
    rejectedAt: e.rejectedAt,
    status: e.status,
  );

  TransactionEntity toEntity() => TransactionEntity(
    id: id,
    title: title,
    concept: concept,
    amount: amount,
    origin: origin,
    destination: destination,
    createdBy: createdBy,
    createdAt: createdAt,
    approvedBy: approvedBy,
    approvedAt: approvedAt,
    rejectedBy: rejectedBy,
    rejectedAt: rejectedAt,
    status: status,
  );
}
