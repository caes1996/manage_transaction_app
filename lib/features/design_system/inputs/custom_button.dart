import 'package:flutter/material.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onTap,
    this.isDisabled = false,
    this.isLoading = false,
    this.outline = false,
    this.margin,
    this.height,
    this.leading,
    this.trailing,
    this.radius = 12,
  });

  final void Function()? onTap;
  final String label;
  final bool isDisabled;
  final bool isLoading;
  final bool outline;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Widget? leading;
  final Widget? trailing;
  final double radius;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canTap = !widget.isDisabled && !widget.isLoading && widget.onTap != null;

    return Container(
      margin: widget.margin,
      height: widget.height,
      constraints: const BoxConstraints(minHeight: 44),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: canTap ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: canTap ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: _decoration(context),
            child: Center(
              child: widget.isLoading
                  ? _buildLoader(context)
                  : _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    final bool outline = widget.outline;
    final bool disabled = widget.isDisabled;

    Color bg;
    BorderSide border;
    List<BoxShadow> shadow = [];

    if (outline) {
      bg = context.surface.withValues(alpha: disabled ? 0.6 : (_hovered ? 0.9 : 1));
      border = BorderSide(color: disabled ? context.onSurface.withValues(alpha: 0.3) : context.primary, width: 1.2);
    } else {
      double base = disabled ? 0.45 : (_pressed ? 0.95 : (_hovered ? 1.0 : 1.0));
      bg = context.primary.withValues(alpha: base);
      border = const BorderSide(color: Colors.transparent, width: 0);
      shadow = [
        if (!disabled && (_hovered || _pressed))
          BoxShadow(color: context.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6)),
      ];
    }

    return BoxDecoration(
      color: outline ? bg : bg,
      borderRadius: BorderRadius.circular(widget.radius),
      border: Border.fromBorderSide(border),
      boxShadow: shadow,
    );
  }

  Widget _buildLoader(BuildContext context) {
    final color = widget.outline ? context.primary : context.onPrimary;
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 3, color: color),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor = widget.isDisabled
        ? Colors.grey.withValues(alpha: 0.6)
        : (widget.outline ? context.primary : context.onPrimary);

    final children = <Widget>[
      if (widget.leading != null) ...[
        widget.leading!,
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: _fontSizeFor(context),
            letterSpacing: 0.3,
          ),
        ),
      ),
      if (widget.trailing != null) ...[
        const SizedBox(width: 8),
        widget.trailing!,
      ],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  double _fontSizeFor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 16; // desktop
    if (w >= 600) return 15; // tablet
    return 14; // phone
  }
}