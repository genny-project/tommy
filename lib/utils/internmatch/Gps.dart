import 'package:geolocator/geolocator.dart';
import 'dart:core';

var gpsData;
var gpsTime;
void getGps() async{
  gpsTime = new DateTime.now().millisecondsSinceEpoch;
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  gpsData = position;
}