import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_maps/data/models/place_suggestion.dart';
import 'package:flutter_maps/presentation/widgets/place_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/place.dart';

class CustomSearchDelegate extends SearchDelegate {
  final Completer<GoogleMapController> mapController;
  final Position position;
  final Function(Marker) onMarkerAdded;

  CustomSearchDelegate({
    required this.mapController,
    required this.position,
    required this.onMarkerAdded,
  });

  List<PlaceSuggestion> places = [];
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late CameraPosition goToSearchedForPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getPlacesSuggestions(query, context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSuggestionsBloc(),
          buildSelectedPlaceLocationBloc(),
        ],
      ),
    );
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (BuildContext context, MapsState state) {
        if (state is PlacesLoaded) {
          places = state.places;
          if (places.isNotEmpty) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lat,
      ),
      zoom: 13,
    );
  }

  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;
          goToMySearchedForLocation();
        }
      },
      child: Container(),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        goToSearchedForPlace,
      ),
    );
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: const MarkerId('one'),
      onTap: () {
        buildCurrentLocationMarker();
      },
      infoWindow: InfoWindow(title: placeSuggestion.description),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersSetAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position.latitude, position.longitude),
      markerId: const MarkerId('two'),
      onTap: () {},
      infoWindow: const InfoWindow(title: 'Your current location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersSetAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersSetAndUpdateUI(Marker marker){
    onMarkerAdded(marker);
  }



  Widget buildPlacesList() {
    return ListView.builder(
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < places.length && index > 0) {
          return InkWell(
            onTap: () async {
              placeSuggestion = places[index];
              getSelectedPlaceLocation(context);
              // TODO ::: ::: :::
              close(context, null);
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        } else {
          // Handle the case where the index is out of bounds
          return const SizedBox(); // Or any other widget or message you want to display
        }
      },
    );
  }

  void getPlacesSuggestions(String query, BuildContext context) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestion(query, sessionToken);
  }

  void getSelectedPlaceLocation(BuildContext context) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }
}
