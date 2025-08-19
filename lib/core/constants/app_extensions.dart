import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';

extension BuildContextExtension on BuildContext {
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get error => Theme.of(this).colorScheme.error;
  Color get onError => Theme.of(this).colorScheme.onError;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;
  Size get size => MediaQuery.of(this).size;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}

enum SizeScreen {mobile, tablet, desktop}
extension SizeScreenExtension on BuildContext {
  bool get isMobile => getScreenSize() == SizeScreen.mobile;
  bool get isTablet => getScreenSize() == SizeScreen.tablet;
  bool get isDesktop => getScreenSize() == SizeScreen.desktop;
  SizeScreen getScreenSize() {
    final size = MediaQuery.sizeOf(this);
    if (size.width < 600) return SizeScreen.mobile;
    if (size.width < 1024) return SizeScreen.tablet;
    return SizeScreen.desktop;
  }
}

extension ColorExtension on Color {
  Color get contrast => computeLuminance() > 0.5 ? Colors.black : Colors.white;
  Color adjustColor(int delta) {
    return Color.fromARGB(
      a.toInt(),
      (r + delta).clamp(0, 255).toInt(),
      (g + delta).clamp(0, 255).toInt(),
      (b + delta).clamp(0, 255).toInt(),
    );
  }
}

extension StringExtension on String {
  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(trim());
  }

  String get capitalize => this[0].toUpperCase() + substring(1);
}

extension UserRoleExtension on UserRole {
  String get displayName => switch (this) {
    UserRole.root => 'Root',
    UserRole.admin => 'Administrador',
    UserRole.transactional => 'Transaccional',
  };

  Color get color => switch (this) {
    UserRole.root => const Color(0xFFE43629),
    UserRole.admin => const Color(0xFF197DCF),
    UserRole.transactional => const Color(0xFF289C2C),
  };
}

extension StatusTransactionExtension on StatusTransaction {
  String get displayName => switch (this) {
    StatusTransaction.pending => 'Pendiente',
    StatusTransaction.approved => 'Aprobada', 
    StatusTransaction.rejected => 'Rechazada',
  };
  
  Color get color => switch (this) {
    StatusTransaction.pending => const Color(0xFFF59E0B),
    StatusTransaction.approved => const Color(0xFF10B981),
    StatusTransaction.rejected => const Color(0xFFEF4444),
  };
  
  IconData get icon => switch (this) {
    StatusTransaction.pending => HugeIcons.strokeRoundedClock01,
    StatusTransaction.approved => HugeIcons.strokeRoundedCheckmarkCircle02,
    StatusTransaction.rejected => HugeIcons.strokeRoundedCancel01,
  };
}