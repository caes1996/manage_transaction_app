import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection.dart';
import 'app.dart';

class SchemaController extends ValueNotifier<String> {
  SchemaController(super.schema);
  void setSchema(String schema) => value = schema;
}

late final SchemaController schemaController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initDependencies();

  schemaController = SchemaController(dotenv.env['DB_SCHEMA']!);

  runApp(ManageTransactionApp(schemaController: schemaController));
}
