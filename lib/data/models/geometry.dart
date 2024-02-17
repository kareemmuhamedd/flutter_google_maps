import 'location.dart';

class Geometry{
  late Location location;
  Geometry.fromJson(dynamic json){
    location = Location.fromJson(json['location']);
  }
}