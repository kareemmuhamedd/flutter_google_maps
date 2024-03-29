import 'package:bloc/bloc.dart';
import 'package:flutter_maps/data/models/place.dart';
import 'package:meta/meta.dart';

import '../../../data/models/place_suggestion.dart';
import '../../../data/repository/maps_repo.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapsInitial());

  void emitPlaceSuggestion(String place, String sessionToken) {
    mapsRepository
        .fetchSuggestions(place, sessionToken)
        .then((List<PlaceSuggestion> suggestions) {
      emit(PlacesLoaded(suggestions));
    });
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    mapsRepository
        .getPlaceLocation(placeId, sessionToken)
        .then((place) {
      emit(PlaceLocationLoaded(place));
    });
  }
}
