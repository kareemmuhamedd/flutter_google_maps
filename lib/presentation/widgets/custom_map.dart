import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../helpers/location_helper.dart';

class CustomMap extends StatefulWidget {
  final Completer<GoogleMapController> mapController;

  const CustomMap({
    Key? key,
    required this.mapController,
  }) : super(key: key);

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  Position? position;
  late CameraPosition _myCameraPositionCurrentLocation;
  bool loading = true;
  String errorMessage = '';
  Set<Marker> markers = {};
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
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
}
