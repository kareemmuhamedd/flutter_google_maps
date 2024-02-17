import 'package:flutter_maps/data/models/result.dart';

class Place{
  late Result result;
  Place.fromJson(dynamic json){
    result = Result.fromJson(json['result']);
  }
}