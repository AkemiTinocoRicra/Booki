import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;
}
