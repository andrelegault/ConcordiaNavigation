import 'dart:convert';
import '../../models/outdoor/reachable.dart';
import 'directions_service.dart';
import 'location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../storage/app_constants.dart' as constants;

//This class is used to generate an an Itinerary from the direction's JSON.
class OutdoorItinerary {
  ///Safety making sure the itinerary is generated only once.
  Map<String, Map<String, String>> _itinerary;
  List<Polyline> _polylines;
  static DirectionsService _directionsService;

  OutdoorItinerary._create();

  String _duration;
  String _distance;

  String get duration => _duration;
  String get distance => _distance;

  List<Polyline> get polylines => _polylines;

  Map<String, Map<String, String>> get itinerary => _itinerary;

  /// Create the Itinerary object and populate its fields from json data.
  static Future<OutdoorItinerary> create(
      LatLng startDestination, LatLng endDestination, String mode,
      [DirectionsService directionsService = const DirectionsService()]) async {
    OutdoorItinerary itinerary = OutdoorItinerary._create();
    _directionsService = directionsService;

    String rawData = await _directionsService
        .getDirections(startDestination, endDestination, mode: mode);
    Map<String, dynamic> rawJson = json.decode(rawData);
    itinerary._polylines = getPolylinePoints(rawJson);
    itinerary._itinerary = getDirectionList(rawJson);
    itinerary._distance = getDistance(rawJson);
    itinerary._duration = getDuration(rawJson);

    return itinerary;
  }

  /// Create the Itinerary object and populate its fields from json data.
  static Future<OutdoorItinerary> fromReachable(
      final Reachable start, final Reachable end, final String mode,
      [DirectionsService directionsService = const DirectionsService()]) async {
    OutdoorItinerary itinerary = OutdoorItinerary._create();
    _directionsService = directionsService;

    LatLng s =
        start?.toLatLng() ?? LocationService.getInstance().current.toLatLng();

    String rawData =
        await _directionsService.getDirections(s, end.toLatLng(), mode: mode);

    Map<String, dynamic> rawJson = json.decode(rawData);
    itinerary._polylines = getPolylinePoints(rawJson);
    itinerary._itinerary = getDirectionList(rawJson);
    itinerary._distance = getDistance(rawJson);
    itinerary._duration = getDuration(rawJson);

    return itinerary;
  }

  /// Returns a Map of instructions obtained by parsing a json object from Google's Directions API.
  ///
  /// The format is the following:
  /// ```
  /// {
  ///   Summary of instruction 1 : {duration, distance},
  ///   Summary of instruction 2 : {duration, distance},
  ///   ...
  /// }
  /// ```
  ///
  /// Sample output:
  /// ```
  /// {
  ///   Head west on Rue Sainte-Catherine O. toward Avenue Atwater : {5 mins: 0.2 km},
  ///   Turn left onto Avenue Atwater : {3 mins: 1.4 km},
  ///   Turn left onto Rue Tupper : {1 min: 0.7 km},
  ///   ...
  /// }
  /// ```
  /// Currently doesn't support subdirections.
  static Map<String, Map<String, String>> getDirectionList(
      Map<String, dynamic> rawJson) {
    Map<String, Map<String, String>> temp = Map<String, Map<String, String>>();
    var steps = rawJson["routes"][0]["legs"][0]["steps"].length;
    for (int i = 0; i < steps; i++) {
      String instructions = rawJson["routes"][0]["legs"][0]["steps"][i]
              ["html_instructions"]
          .replaceAll(constants.removeHTML, ' ');
      String directionText =
          rawJson["routes"][0]["legs"][0]["steps"][i]["duration"]["text"];
      temp.addAll({
        instructions: {directionText: directionText}
      });
    }
    return temp;
  }

  /// Returns a list of Polylines obtained by parsing a json object from Google's Directions API.
  /// similar to [getDirectionList(Map<String, dynamic>)] but returns a list of Polyline objects instead of a Map of directions.
  static List<Polyline> getPolylinePoints(Map<String, dynamic> rawJson) {
    PolylinePoints tPolylinePoints = PolylinePoints();
    List<PointLatLng> tPointLatLng = [];
    List<Polyline> tPolyline = [];

    var steps =
        rawJson['routes'][0]['legs'][0]['steps']; // # of direction steps

    for (int i = 0; i < steps.length; i++) {
      // get polyline of every steps
      dynamic directions = steps[i]["polyline"]["points"];
      List<PointLatLng> temp = tPolylinePoints.decodePolyline(directions);
      tPointLatLng = new List.from(tPointLatLng)..addAll(temp);
    }
    List<LatLng> po = [];
    tPointLatLng.forEach((f) {
      po.add(LatLng(f.latitude, f.longitude));
    });

    Polyline route = new Polyline(
      polylineId: PolylineId("route"),
      geodesic: true,
      points: po,
      width: 5,
      color: Colors.blue,
    );

    tPolyline.add(route);
    return tPolyline;
  }

  static String getDuration(Map<String, dynamic> rawJson) {
    return rawJson['routes'][0]['legs'][0]['duration']['text'];
  }

  static String getDistance(Map<String, dynamic> rawJson) {
    return rawJson['routes'][0]['legs'][0]['distance']['text'];
  }
}
