// lib/features/settings/domain/settings_registry.dart

import 'package:flutter/material.dart';

class SettingsSection {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext) builder;
  final String? subtitle;
  final bool enabled;

  const SettingsSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
    this.subtitle,
    this.enabled = true,
  });
}

class SettingsRegistry {
  static SettingsRegistry? _instance;
  static SettingsRegistry get instance => _instance ??= SettingsRegistry._();
  
  SettingsRegistry._();
  
  factory SettingsRegistry() => instance;

  final Map<String, SettingsSection> _sections = {};

  /// Registra una sección individual
  void register(SettingsSection section) {
    _sections[section.id] = section;
  }

  /// Registra múltiples secciones de una vez
  void registerAll(List<SettingsSection> sections) {
    for (final section in sections) {
      register(section);
    }
  }

  /// Obtiene una sección por ID
  SettingsSection? byId(String id) => _sections[id];

  /// Obtiene todas las secciones registradas
  List<SettingsSection> get all => _sections.values.toList();
  
  /// Alias para compatibilidad - mismo que 'all'
  List<SettingsSection> get sections => all;

  /// Obtiene secciones habilitadas
  List<SettingsSection> get enabled => 
      _sections.values.where((s) => s.enabled).toList();

  /// Verifica si una sección existe
  bool contains(String id) => _sections.containsKey(id);

  /// Remueve una sección
  void unregister(String id) => _sections.remove(id);

  /// Limpia todas las secciones
  void clear() => _sections.clear();

  /// Obtiene el conteo de secciones
  int get count => _sections.length;
}