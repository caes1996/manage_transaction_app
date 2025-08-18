import 'package:flutter/material.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';

class DropdownData<T> {
  const DropdownData({
    required this.value,
    required this.displayText,
    this.id,
    this.iconColor,
    this.iconText,
    this.searchableText,
  });

  final T value;
  final String displayText;
  final String? id;
  final Color? iconColor;
  final String? iconText;
  final String? searchableText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownData<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class CustomDropdownInput<T> extends StatefulWidget {
  const CustomDropdownInput({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.hint,
    this.label,
    this.width,
    this.height = 50,
    this.margin = const EdgeInsets.only(top: 24),
    this.selectedTextStyle,
    this.itemTextStyle,
    this.popupWidth,
    this.dropdownIcon,
    this.prefixIcon,
    this.enabled = true,
    this.errorText,
    this.isRequired = false,
    this.readOnly = false,
    this.showSearch = false,
    this.searchHint = 'Buscar...',
    this.noItemsFoundText = 'No se encontraron elementos',
    this.maxHeight = 300,
  });

  final List<DropdownData<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? label;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final TextStyle? selectedTextStyle;
  final TextStyle? itemTextStyle;
  final double? popupWidth;
  final Widget? dropdownIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final String? errorText;
  final bool isRequired;
  final bool readOnly;
  final bool showSearch;
  final String searchHint;
  final String noItemsFoundText;
  final double maxHeight;

  @override
  State<CustomDropdownInput<T>> createState() => _CustomDropdownInputState<T>();
}

class _CustomDropdownInputState<T> extends State<CustomDropdownInput<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _displayController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<DropdownData<T>> _filteredItems = [];
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _focusNode.addListener(_onFocusChange);
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(covariant CustomDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = List.from(widget.items);
      if (_isOverlayVisible) _updateOverlay();
    }
    if (oldWidget.selectedValue != widget.selectedValue) {
      _updateDisplayText();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _searchController.dispose();
    _displayController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_searchFocusNode.hasFocus) _removeOverlay();
      });
    }
  }

  void _updateDisplayText() {
    if (!mounted) return;
    _displayController.text = _getDisplayText();
  }

  void _filterItems(String query) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (query.isEmpty) {
          _filteredItems = List.from(widget.items);
        } else {
          final q = query.toLowerCase().trim();
          _filteredItems = widget.items.where((item) {
            final a = item.displayText.toLowerCase();
            final b = item.searchableText?.toLowerCase() ?? '';
            return a.contains(q) || b.contains(q);
          }).toList();
        }
      });
      _updateOverlay();
    });
  }

  void _showOverlay() {
    if (_isOverlayVisible || !mounted) return;
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow = screenHeight - offset.dy - size.height;
    final spaceAbove = offset.dy;
    final showAbove = spaceBelow < widget.maxHeight && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: showAbove ? null : offset.dy + size.height + 4,
            bottom: showAbove ? screenHeight - offset.dy + 4 : null,
            width: widget.popupWidth ?? size.width,
            child: _buildDropdownContent(),
          ),
        ],
      ),
    );

    _isOverlayVisible = true;
    Overlay.of(context).insert(_overlayEntry!);

    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  Widget _buildDropdownContent() {
    final outline = Theme.of(context).colorScheme.outline;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.black26,
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSearch) ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterItems('');
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: outline.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: outline.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: _filterItems,
                ),
              ),
              if (_filteredItems.isNotEmpty)
                Divider(height: 1, color: outline.withValues(alpha: 0.2)),
            ],
            Flexible(
              child: _filteredItems.isEmpty
                  ? _buildNoItemsFound()
                  : _buildItemsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    final onSurface = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: onSurface),
          const SizedBox(height: 8),
          Text(
            widget.noItemsFoundText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _filteredItems.length,
      itemBuilder: (context, i) {
        final item = _filteredItems[i];
        final isSelected = item.value == widget.selectedValue;
        return _buildDropdownItem(item, isSelected);
      },
    );
  }

  Widget _buildDropdownItem(DropdownData<T> item, bool isSelected) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => _selectItem(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? primary.withValues(alpha: 0.08) : null,
        ),
        child: Row(
          children: [
            if (item.iconColor != null && item.iconText != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    item.iconText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.displayText,
                overflow: TextOverflow.ellipsis,
                style: widget.itemTextStyle ??
                    context.bodyMedium.copyWith(
                      color: isSelected
                          ? primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            ]
          ],
        ),
      ),
    );
  }

  void _selectItem(DropdownData<T> item) {
    widget.onChanged?.call(item.value);
    _updateDisplayText();
    _removeOverlay();
    _focusNode.unfocus();
  }

  String _getDisplayText() {
    if (widget.selectedValue == null) return '';
    try {
      final selected = widget.items.firstWhere(
        (e) => e.value == widget.selectedValue,
      );
      return selected.displayText;
    } catch (_) {
      return '';
    }
  }

  void _updateOverlay() {
    if (_overlayEntry != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlayEntry != null && mounted) {
          _overlayEntry!.markNeedsBuild();
        }
      });
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
    _searchController.clear();
    _filteredItems = List.from(widget.items);
    _searchFocusNode.unfocus();
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final hasValue = widget.selectedValue != null;
    final hasError = widget.errorText != null;
    final outline = Theme.of(context).colorScheme.outline;

    return InputDecoration(
      filled: true,
      fillColor: widget.readOnly ? context.surface : Colors.grey[50],
      hintText: !hasValue ? (widget.hint ?? widget.label) : null,
      hintStyle: context.bodyMedium.copyWith(
        color: context.onSurface.withValues(alpha: 0.6),
      ),
      label: hasValue
          ? Text.rich(
              TextSpan(children: [
                TextSpan(text: widget.label ?? widget.hint ?? ''),
                if (widget.isRequired)
                  TextSpan(text: ' *', style: TextStyle(color: context.error)),
              ]),
            )
          : null,
      floatingLabelStyle: context.bodyMedium.copyWith(
        color: hasError ? context.error : context.onSurface.withValues(alpha: 0.6),
      ),
      errorText: widget.errorText,
      errorStyle: context.bodySmall.copyWith(color: context.error),
      labelStyle: context.bodyLarge.copyWith(
        color: context.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: hasError ? context.error : context.primary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: hasError ? context.error.withValues(alpha: 0.5) : outline.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: context.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: context.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: outline.withValues(alpha: 0.3), width: 1),
      ),
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.dropdownIcon ?? AnimatedRotation(
        turns: _isOverlayVisible ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.expand_more,
          color: widget.enabled
              ? context.onSurface.withValues(alpha: 0.7)
              : context.onSurface.withValues(alpha: 0.4),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final base = context.bodyMedium;
    if (widget.readOnly) {
      return base.copyWith(color: context.onSurface.withValues(alpha: 0.6));
    }
    return widget.selectedTextStyle ?? base.copyWith(color: context.onSurface);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        margin: widget.margin,
        height: widget.height,
        width: widget.width,
        child: Focus(
          focusNode: _focusNode,
          child: GestureDetector(
            onTap: widget.enabled && !widget.readOnly
                ? () {
                    if (_isOverlayVisible) {
                      _removeOverlay();
                    } else {
                      _focusNode.requestFocus();
                      _showOverlay();
                    }
                  }
                : null,
            child: TextFormField(
              enabled: false,
              decoration: _buildDecoration(context),
              style: _getTextStyle(context),
              controller: _displayController,
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownUtils {
  static Container buildContainer(EdgeInsets? margin, {required Widget child, double? height}) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  static TextStyle getTextStyle(BuildContext context, bool readOnly) {
    final theme = Theme.of(context);
    return readOnly
        ? context.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )
        : context.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          );
  }
}