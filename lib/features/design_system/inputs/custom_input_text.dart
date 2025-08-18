import 'package:flutter/material.dart';
import 'base_input.dart';

class CustomInputText extends BaseInputText {
  const CustomInputText({
    super.key,
    required this.controller,
    super.hint,
    super.label,
    super.readOnly,
    super.obscureText,
    super.keyboardType,
    super.maxLines,
    super.margin,
    super.height,
    super.errorText,
    super.prefixIcon,
    super.textCapitalization,
    this.onChanged,
  });

  final TextEditingController controller;
  final void Function(String value)? onChanged;

  @override
  State<CustomInputText> createState() => _CustomInputTextState();
}

class _CustomInputTextState extends State<CustomInputText> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return InputUtils.buildContainer(
      widget.margin,
      height: widget.height,
      child: TextField(
        readOnly: widget.readOnly,
        obscureText: widget.obscureText ? _obscured : false,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        textCapitalization: widget.textCapitalization,
        style: InputUtils.getTextStyle(context, widget.readOnly),
        decoration: InputUtils.buildDecoration(
          context,
          widget.hint,
          widget.errorText,
          widget.readOnly,
          widget.obscureText,
          () => setState(() => _obscured = !_obscured),
          _obscured,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }
}

class CustomInputTextForm extends BaseInputText {
  const CustomInputTextForm({
    super.key,
    super.hint,
    super.label,
    super.readOnly,
    super.obscureText,
    super.keyboardType,
    super.maxLines,
    super.margin,
    super.height,
    super.errorText,
    super.prefixIcon,
    super.textCapitalization,
    this.initialValue,
    this.isRequired = true,
    this.textValidator,
    this.validationRules = const [],
    this.onSaved,
    this.onChanged,
  });

  final bool isRequired;
  final String? textValidator;
  final List<ValidationRule> validationRules;
  final void Function(String? newValue)? onSaved;
  final void Function(String value)? onChanged;
  final String? initialValue;

  @override
  State<CustomInputTextForm> createState() => _CustomInputTextFormState();
}

class _CustomInputTextFormState extends State<CustomInputTextForm> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return InputUtils.buildContainer(
      widget.margin,
      height: widget.height,
      child: TextFormField(
        initialValue: widget.initialValue,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText ? _obscured : false,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: InputUtils.getTextStyle(
          context,
          widget.readOnly,
          widget.isRequired,
        ),
        validator: _validateField,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        textCapitalization: widget.textCapitalization,
        decoration: InputUtils.buildDecoration(
          context,
          widget.hint,
          widget.errorText,
          widget.readOnly,
          widget.obscureText,
          () => setState(() => _obscured = !_obscured),
          _obscured,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }

  String? _validateField(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return widget.textValidator ?? 'El campo es obligatorio';
    }
    for (final rule in widget.validationRules) {
      if (!rule.condition(value)) {
        return rule.errorMessage;
      }
    }
    return null;
  }
}

class CustomInputTextArea extends BaseInputText {
  const CustomInputTextArea({
    super.key,
    required this.controller,
    super.hint,
    super.label,
    super.readOnly,
    TextInputType super.keyboardType = TextInputType.multiline,
    int super.maxLines = 5,
    super.margin,
    super.height,
    super.errorText,
    super.prefixIcon,
    super.textCapitalization,
    this.onChanged,
    this.maxLength,
  }) : super(obscureText: false);

  final TextEditingController controller;
  final void Function(String value)? onChanged;
  final int? maxLength;

  @override
  State<CustomInputTextArea> createState() => _CustomInputTextAreaState();
}

class _CustomInputTextAreaState extends State<CustomInputTextArea> {
  @override
  Widget build(BuildContext context) {
    final minLines = (widget.maxLines != null && widget.maxLines! > 1)
        ? (widget.maxLines! - 2).clamp(1, widget.maxLines!)
        : null;

    return InputUtils.buildContainer(
      widget.margin,
      height: widget.height,
      child: TextField(
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        maxLines: widget.maxLines,
        minLines: minLines,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        textCapitalization: widget.textCapitalization,
        style: InputUtils.getTextStyle(context, widget.readOnly),
        decoration: InputUtils.buildDecoration(
          context,
          widget.hint,
          widget.errorText,
          widget.readOnly,
          false,
          () {},
          false,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }
}

class CustomInputTextAreaForm extends BaseInputText {
  const CustomInputTextAreaForm({
    super.key,
    super.hint,
    super.label,
    super.readOnly,
    TextInputType super.keyboardType = TextInputType.multiline,
    int super.maxLines = 5,
    super.margin,
    super.height,
    super.errorText,
    super.prefixIcon,
    super.textCapitalization,
    this.initialValue,
    this.isRequired = true,
    this.textValidator,
    this.validationRules = const [],
    this.onSaved,
    this.onChanged,
    this.maxLength,
  }) : super(obscureText: false);

  final bool isRequired;
  final String? textValidator;
  final List<ValidationRule> validationRules;
  final void Function(String? newValue)? onSaved;
  final void Function(String value)? onChanged;
  final String? initialValue;
  final int? maxLength;

  @override
  State<CustomInputTextAreaForm> createState() => _CustomInputTextAreaFormState();
}

class _CustomInputTextAreaFormState extends State<CustomInputTextAreaForm> {
  @override
  Widget build(BuildContext context) {
    final minLines = (widget.maxLines != null && widget.maxLines! > 1)
        ? (widget.maxLines! - 2).clamp(1, widget.maxLines!)
        : null;

    return InputUtils.buildContainer(
      widget.margin,
      height: widget.height,
      child: TextFormField(
        initialValue: widget.initialValue,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        minLines: minLines,
        maxLength: widget.maxLength,
        style: InputUtils.getTextStyle(
          context,
          widget.readOnly,
          widget.isRequired,
        ),
        validator: _validateField,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        textCapitalization: widget.textCapitalization,
        decoration: InputUtils.buildDecoration(
          context,
          widget.hint,
          widget.errorText,
          widget.readOnly,
          false,
          () {},
          false,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }

  String? _validateField(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return widget.textValidator ?? 'El campo es obligatorio';
    }
    for (final rule in widget.validationRules) {
      if (!rule.condition(value)) {
        return rule.errorMessage;
      }
    }
    return null;
  }
}