import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manage_transaction_app/features/auth/domain/entities/user_entity.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:manage_transaction_app/features/auth/presentation/bloc/auth/auth_state.dart';

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

extension UserContextExtension on BuildContext {
  UserEntity? get currentUser {
    return select<AuthBloc, UserEntity?>((bloc) {
      final s = bloc.state;
      return s is AuthAuthenticated ? s.user : null;
    });
  }

  bool get isLoggedIn {
    final s = read<AuthBloc>().state;
    return s is AuthAuthenticated;
  }
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