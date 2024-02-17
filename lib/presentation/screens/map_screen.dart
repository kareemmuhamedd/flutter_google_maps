import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps/constants/colors.dart';
import 'package:flutter_maps/data/models/place.dart';
import 'package:flutter_maps/data/models/place_suggestion.dart';
import 'package:flutter_maps/helpers/location_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/custom_search_delegate.dart';
import '../widgets/my_drawer.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? position;
  late CameraPosition _myCameraPositionCurrentLocation;
  bool loading = true;
  String errorMessage = '';

  // this variables for getPlacesLocation
  Set<Marker> markers = {};
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;

  late CameraPosition goToSearchedForPlace;

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    Position? currentPosition = await LocationHelper.getCurrentLocation();

    if (currentPosition != null) {
      _myCameraPositionCurrentLocation = CameraPosition(
        target: LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        ),
        bearing: 0.0,
        tilt: 0.0,
        zoom: 17,
      );
      setState(() {
        position = currentPosition;
      });
    } else {
      setState(() {
        errorMessage =
            'Failed to get location. Please enable location services and try again.';
      });
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(_myCameraPositionCurrentLocation),
    );
  }

  Widget buildMap() {
    return GoogleMap(
      initialCameraPosition: _myCameraPositionCurrentLocation,
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
    );
  }

  Widget buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _getCurrentLocation(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void onMarkerAdded(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  mapController: _mapController,
                  position: position!,
                  onMarkerAdded: onMarkerAdded,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      // drawer: MyDrawer(),
      body: Stack(
        children: [
          position != null
              ? buildMap()
              // ? Container(color: Colors.green,)
              : loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    )
                  : buildErrorMessage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        onPressed: () => _goToMyCurrentLocation(),
        child: const Icon(
          Icons.place,
          color: Colors.white,
        ),
      ),
    );
  }
}
