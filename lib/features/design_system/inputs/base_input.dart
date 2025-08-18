import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';

/// Color principal tomado del diseño de referencia (#667eea)
const Color _kPrimaryAccent = Color(0xFF667eea);

/// Reglas de validación reutilizables
class ValidationRule {
  const ValidationRule({
    required this.condition,
    required this.errorMessage,
  });

  final bool Function(String? value) condition;
  final String errorMessage;

  factory ValidationRule.minLength(int length) => ValidationRule(
        condition: (value) => (value?.length ?? 0) >= length,
        errorMessage: 'El campo debe tener al menos $length caracteres',
      );

  factory ValidationRule.maxLength(int length) => ValidationRule(
        condition: (value) => (value?.length ?? 0) <= length,
        errorMessage: 'El campo debe tener máximo $length caracteres',
      );

  factory ValidationRule.notEmpty([String msg = 'El campo es obligatorio']) =>
      ValidationRule(
        condition: (value) => (value?.trim().isNotEmpty ?? false),
        errorMessage: msg,
      );
}

/// Base común para inputs de texto (TextField/TextFormField)
abstract class BaseInputText extends StatefulWidget {
  const BaseInputText({
    super.key,
    this.hint,
    this.label,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.margin = const EdgeInsets.only(top: 24),
    this.errorText,
    this.prefixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.height,
  });

  final String? hint;
  final String? label;
  final bool readOnly;
  final int? maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final EdgeInsets? margin;
  final String? errorText;
  final Widget? prefixIcon;
  final TextCapitalization textCapitalization;
  final double? height;
}

/// Utils compartidos para estilo y decoración
class InputUtils {
  static Container buildContainer(
    EdgeInsets? margin, {
    required Widget child,
    double? height,
  }) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// Toma en cuenta modo de lectura y requerido para el color del texto
  static TextStyle getTextStyle(
    BuildContext context,
    bool readOnly, [
    bool isRequired = false,
  ]) {
    final base = context.bodyMedium;
    final color = readOnly
        ? context.onSurface.withValues(alpha: 0.6)
        : context.onSurface;
    return base.copyWith(
      color: color,
      fontSize: _fontSizeFor(context),
    );
  }

  /// Tamaños responsivos según ancho
  static double _fontSizeFor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 16; // desktop
    if (w >= 600) return 15; // tablet
    return 14; // phone
  }

  static double iconSizeFor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 24;
    if (w >= 600) return 22;
    return 20;
  }

  static double verticalPaddingFor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 16;
    if (w >= 600) return 14;
    return 12;
  }

  /// Construye la decoración siguiendo el patrón del widget de referencia
  static InputDecoration buildDecoration(
    BuildContext context,
    String? hint,
    String? errorText,
    bool readOnly,
    bool isPassword,
    VoidCallback toggleVisibility,
    bool obscured, {
    Widget? prefixIcon,
    bool isRequired = false,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );

    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      labelText: hint,
      labelStyle: context.bodyMedium.copyWith(
        color: Colors.grey[600],
        fontSize: getTextStyle(context, readOnly).fontSize! - 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: verticalPaddingFor(context),
      ),
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon ??
          (!isPassword
              ? null
              : GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    obscured
                        ? HugeIcons.strokeRoundedView
                        : HugeIcons.strokeRoundedViewOff,
                    color: _kPrimaryAccent,
                    size: iconSizeFor(context),
                  ),
                )),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _kPrimaryAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      // Indicador visual de requerido en el label flotante
      floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: errorText != null ? theme.colorScheme.error : Colors.grey[700],
      ),
    );
  }

  /// Prefijo con ícono según tono de marca
  static Widget buildPrefixIcon(IconData icon, BuildContext context) => Icon(
        icon,
        color: _kPrimaryAccent,
        size: iconSizeFor(context),
      );
}