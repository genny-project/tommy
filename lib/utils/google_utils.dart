import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_utils.g.dart';


class GoogleUtils {
  static UniqueKey sessionToken = UniqueKey();
  static Future<PlacesResult> getSuggestions(String query, String key) async {
    Response response = await get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=address&language=en&components=country:au&key=$key&sessiontoken=$sessionToken"));
    return PlacesResult.fromJson(jsonDecode(response.body));
  }
  static Future<Response> getPlaceData(String placeId, String key) async {
    Response response = await get(Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key"));
    return response;
  }
}


@JsonSerializable()
class Prediction {
  final String description;
  final String reference;
  @JsonKey(name: 'place_id')
  final String? placeId;
  final List<String> types;
  Prediction({required this.description, required this.reference, this.placeId, required this.types});
  factory Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionToJson(this);
}


@JsonSerializable()
class PlacesResult {
  final List<Prediction> predictions;
  final String status;
  PlacesResult({required this.predictions, required this.status});
  factory PlacesResult.fromJson(Map<String, dynamic> json) => _$PlacesResultFromJson(json);
  Map<String, dynamic> toJson() => _$PlacesResultToJson(this);
}