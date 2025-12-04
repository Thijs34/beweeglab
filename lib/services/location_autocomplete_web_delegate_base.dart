import 'location_autocomplete_models.dart';

abstract class LocationAutocompleteWebDelegate {
  Future<List<LocationPrediction>> fetchSuggestions(String input);
  void dispose();
}
