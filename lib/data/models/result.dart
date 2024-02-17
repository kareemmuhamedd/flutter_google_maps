import 'geometry.dart';

class Result{
  late Geometry geometry;
  Result.fromJson(dynamic json){
    geometry = Geometry.fromJson(json['geometry']);
  }
}