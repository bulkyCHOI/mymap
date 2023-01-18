import 'dart:convert';
import 'dart:math';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert ;

class LocationService{
  final String key = 'AIzaSyA4TgUKzpYzWqFFzik8uqtu816xAkpMhnc';

  Future<String> getPlaceId(String input) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;
    // print(placeId);
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async{
    final placeId = await getPlaceId(input);
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    print(results);
    return results;
  }

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async{
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    // print(json);
    // print("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };
    // print(results);
    // print("\n------------------------------------------------------------------\n");
    return results;
  }

  Future<double> getDistance(LatLng ne, LatLng sw) async {
    String neLatLng = ne.latitude.toString()+","+ne.longitude.toString();
    String swLatLng = sw.latitude.toString()+","+sw.longitude.toString();
    print(neLatLng);
    print(swLatLng);
    final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=transit&origins=$neLatLng&destinations=$swLatLng&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    print(json);
    // print("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    // var result = json['rows']['elements']['distance']['value'];
    var distance = json['rows'][0]['elements'][0]['distance']['value'];
    var zoomLevel = log2(38000*cos((ne.latitude-sw.latitude).abs())/distance/1000)+23.0;
    print('zoomLevel: $zoomLevel');
    return zoomLevel;
  }

  int log2(num x) => (log(x) / log(2)).floor();

  Future<List<dynamic>> getSuggestion(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$key';

    var response = await http.get(Uri.parse(request));
    // print(response.body.toString());
    // print(data);
    if (response.statusCode == 200) {
        var results = jsonDecode(response.body.toString())['predictions'];
        return results;
    } else {
      throw Exception('Failed to load data');
    }
  }
}