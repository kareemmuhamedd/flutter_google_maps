class Location {
  late double lat;
  late double lng;

  Location.fromJson(dynamic json) {
    lat = json['lat'];
    lng = json['lng'];
  }
}
