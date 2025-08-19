# Manage Transaction App

Aplicación Flutter para gestionar transacciones con autenticación, roles y actualizaciones en tiempo real usando **Supabase**.

---
## Objetivo

- Registro y gestión de **transacciones**.
- Administración de **usuarios** con roles (p. ej. `root`, `admin`, `transactional`).
- **Tiempo real** (Realtime) para listar/actualizar sin refrescar vistas.
- Arquitectura limpia con **data → domain → presentation** y **BLoC**.
---
## Stack técnico

- **Flutter** (Dart 3.8+)
- **BLoC** (`flutter_bloc`)
- **Supabase** (`supabase_flutter`)
- **GoRouter** para navegación
- **get_it** para inyección de dependencias
- **flutter_dotenv** para variables de entorno
- **google_fonts / hugeicons** para UI
---
##  Decisiones técnicas

  ### ¿Por qué Supabase?
- El proyecto requiere **actualizaciones en tiempo real** sobre **PostgreSQL**.
- Se evaluó **Firebase** y un backend con **FastAPI**:
	- **Firebase** fue descartado porque el dominio del problema es fuertemente **relacional** y se necesitaban **SQL** flexible.
	- **FastAPI** fue descartado como backend principal por el requisito de **Realtime** nativo y por el costo de construir/operar toda la capa de auth, sockets y policies.
- **Supabase** ofrece:
	- Auth integrado, **PostgreSQL** con **RLS**, funciones SQL/Triggers y **Realtime** con mínima fricción.
	- Muy buen encaje con Flutter vía `supabase_flutter`.
---
## Arquitectura & Estructura de carpetas

Arquitectura por **features** + capas:
```bash
lib/
├─ core/
│  ├─ constants/         # temas, rutas, helpers globales
│  ├─ layouts/           # AppShell, contenedores comunes
│  └─ utils/             # funciones utilitarias
│
├─ features/
│  ├─ auth/
│  │  ├─ data/
│  │  │  ├─ datasources/     # Supabase clients
│  │  │  ├─ models/          # DTOs ↔ DB
│  │  │  └─ repositories/    # Implementaciones repo
│  │  ├─ domain/
│  │  │  ├─ entities/        # Entidades de dominio
│  │  │  └─ repositories/    # Abstracciones repo
│  │  └─ presentation/
│  │     ├─ bloc/            # AuthBloc & UserBloc (si aplica)
│  │     ├─ pages/           # Login, Users, ProfileSettings
│  │     └─ widgets/         # Componentes UI reusables
│  │
│  └─ transactions/
│     ├─ data/
│     ├─ domain/
│     └─ presentation/
│        ├─ bloc/
│        ├─ pages/
│        └─ widgets/
│
├─ features/design_system/    # Inputs, botones, components base
│
├─ app.dart                   # MaterialApp + GoRouter setup
├─ injection.dart             # get_it: registration
└─ main.dart                  # entrypoint
```


**Reglas:**  
- `pages/` **no** deberían tener lógica de negocio; orquestan UI y disparan eventos BLoC.  
- `widgets/` solo presentación / pequeñas interacciones.  
- `data/` habla con Supabase/HTTP; **no** se usa en UI directamente.  
- `domain/` define entidades y contratos; no conoce de Supabase ni Flutter.

---

## Base de datos

- **Tablas principales** (Schema de pruebas: `mock_data`):
  - `mock_data.users` (perfil de usuario; `id` = `auth.users.id`)
  - `mock_data.transactions` (transacciones; FK a usuarios)
- **Auth**: `auth.users` es manejada por Supabase.
- **Realtime**: habilitado en `transactions`.

> **Advertencia**: Al crear un nuevo usuario desde una sesión root o admin, la sesión activa cambia por error al usuario recién creado.

---

## Configuración del entorno

Crea un archivo `.env` en la raíz del proyecto (ya está referenciado en `pubspec.yaml`):
```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
DB_SCHEMA_TEST=<schema_test>
DB_SCHEMA_PROD=<shcema_production>
```

---
## Cómo ejecutar el proyecto
```
# 1. Instalar dependencias
flutter pub get

# 2. (Opcional) Limpieza
flutter clean && flutter pub get

# 3. Ejecutar (elige el dispositivo)
flutter run -d chrome
# o
flutter run -d macos
# o
flutter run -d ios
# o
flutter run -d android
```

**Requisitos previos:**
- Flutter SDK actualizado (Dart 3.8+).
- Dispositivo/emulador configurado.
- Variables del `.env` válidas.

---
## Navegación

- **GoRouter** centraliza rutas en `core/constants/app_routes.dart`.
- **AppShell** (en `core/layouts/app_shell.dart`) provee scaffolding (app bar, navegación lateral, etc.).

---
##  Inyección de dependencias

- **get_it** en `injection.dart`:
    - Registra repositorios (`AuthRepository`, `TransactionRepository`, etc.) y data sources.
    - Registra BLoCs con `factory` / `lazySingleton`.

---

## Design System

- `features/design_system/`
    - **inputs/**: `base_input.dart`, `custom_input_text.dart`, `custom_dropdown_input.dart`
    - **buttons/**: `custom_button.dart`
    - **components/**: `empty_state.dart`, `section_title.dart`

---

## Realtime (Supabase)

Ejemplo de stream en un `RemoteDataSource`:

```dart
Stream<List<TransactionModel>> streamTransactions() {
  return client
    .schema('mock_data')
    .from('transactions')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .map((rows) => rows.map(TransactionModel.fromDb).toList());
}
```

---

## Build

Web:
```bash
flutter build web --release
```

Android:
```bash
flutter build apk --release
```

iOS (requiere Xcode):
```bash
flutter build ios --release
```
