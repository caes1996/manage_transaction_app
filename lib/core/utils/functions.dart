import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';

class Utils {

  // Formatear fecha para mostrar en la UI
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hace unos segundos';
        } else {
          return 'Hace ${difference.inMinutes} min';
        }
      } else {
        return 'Hace ${difference.inHours}h';
      }
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // Formatear fecha completa
  static String formatFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Obtener iniciales del nombre
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
  }

  // Formatear monto con separadores de miles
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Generar color basado en string (para avatares)
  static Color getColorFromString(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final hue = (hash % 360).abs() / 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.6, 0.8).toColor();
  }
}


// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  // Formatear fecha
  String get formatted => Utils.formatDate(this);
  
  // Formatear fecha completa
  String get fullFormatted => Utils.formatFullDate(this);
  
  // Verificar si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  // Verificar si es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

// Extensiones para double (montos)
extension DoubleExtensions on double {
  // Formatear como moneda
  String get currency => Utils.formatCurrency(this);
  
  // Verificar si es un monto válido
  bool get isValidAmount => this > 0 && this <= 1000000;
}

// Clase para estadísticas de transacciones
class TransactionStats {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final double totalAmount;
  final double approvedAmount;
  
  TransactionStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.totalAmount,
    required this.approvedAmount,
  });
  
  static TransactionStats fromTransactions(List<TransactionEntity> transactions) {
    return TransactionStats(
      total: transactions.length,
      pending: transactions.where((t) => t.status == StatusTransaction.pending).length,
      approved: transactions.where((t) => t.status == StatusTransaction.approved).length,
      rejected: transactions.where((t) => t.status == StatusTransaction.rejected).length,
      totalAmount: transactions.fold(0, (sum, t) => sum + t.amount),
      approvedAmount: transactions
          .where((t) => t.status == StatusTransaction.approved)
          .fold(0, (sum, t) => sum + t.amount),
    );
  }
  
  double get approvalRate => total > 0 ? (approved / total) * 100 : 0;
  double get rejectionRate => total > 0 ? (rejected / total) * 100 : 0;
  double get pendingRate => total > 0 ? (pending / total) * 100 : 0;
}

// Filtros para transacciones
class TransactionFilters {
  final StatusTransaction? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  
  const TransactionFilters({
    this.status,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });
  
  TransactionFilters copyWith({
    StatusTransaction? status,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) {
    return TransactionFilters(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  List<TransactionEntity> applyTo(List<TransactionEntity> transactions) {
    return transactions.where((transaction) {
      // Filtro por estado
      if (status != null && transaction.status != status) return false;
      
      // Filtro por fecha desde
      if (fromDate != null && transaction.createdAt.isBefore(fromDate!)) return false;
      
      // Filtro por fecha hasta
      if (toDate != null && transaction.createdAt.isAfter(toDate!)) return false;
      
      // Filtro por monto mínimo
      if (minAmount != null && transaction.amount < minAmount!) return false;
      
      // Filtro por monto máximo
      if (maxAmount != null && transaction.amount > maxAmount!) return false;
      
      // Filtro por búsqueda
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        final matchesTitle = transaction.title.toLowerCase().contains(query);
        final matchesConcept = transaction.concept.toLowerCase().contains(query);
        final matchesOrigin = transaction.origin.toLowerCase().contains(query);
        final matchesDestination = transaction.destination.toLowerCase().contains(query);
        
        if (!matchesTitle && !matchesConcept && !matchesOrigin && !matchesDestination) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
}