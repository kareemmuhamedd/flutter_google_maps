import 'package:flutter_maps/data/models/place.dart';
import 'package:flutter_maps/data/models/place_suggestion.dart';
import 'package:flutter_maps/data/web_services/places_web_services.dart';

class MapsRepository {
  final PlacesWebservices placesWebservices;

  MapsRepository(this.placesWebservices);

  Future<List<PlaceSuggestion>> fetchSuggestions(
    String place,
    String sessionToken,
  ) async {
    final suggestions = await placesWebservices.fetchSuggestions(
      place,
      sessionToken,
    );
    return suggestions
        .map((suggestion) => PlaceSuggestion.fromJson(suggestion))
        .toList();
  }

  Future<Place> getPlaceLocation(
      String placeId,
      String sessionToken,
      ) async {
    final place = await placesWebservices.getPlaceLocation(
      placeId,
      sessionToken,
    );
    Place readyPlace = Place.fromJson(place);
    return readyPlace;
  }
}
