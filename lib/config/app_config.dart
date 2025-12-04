import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String? get googlePlacesApiKey {
    final value = dotenv.env['GOOGLE_PLACES_API_KEY'];
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
