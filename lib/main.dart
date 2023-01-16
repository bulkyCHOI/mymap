//main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mymap/location_service.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

// import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  // TextEditingController _originController = TextEditingController();
  // TextEditingController _destinationController = TextEditingController();
  TextEditingController _seachController = TextEditingController();
  FocusNode _focus = FocusNode();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placeList = [];

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  Set<Polyline> _polylines = Set<Polyline>();
  MapType _currentMapType = MapType.normal;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  int _markerCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _setMarker(LatLng(37.42796133580664, -122.085749655962));
    _seachController.addListener(() {
      if (_focus.hasFocus) onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_seachController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = 'AIzaSyA4TgUKzpYzWqFFzik8uqtu816xAkpMhnc';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    // print(data);
    if (response.statusCode == 200) {
      setState(() {
        _placeList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('marker' + _markerCounter.toString()),
            position: point),
      );
      _markerCounter++;
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    var result = points
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    _polylines.add(Polyline(
      polylineId: PolylineId(polylineIdVal),
      width: 2,
      color: Colors.blue,
      // points: points
      //   .map(
      //     (point) => LatLng(point.latitude, point.longitude),
      // ).toList(),
      points: result,
    ));
    print(points);
    print("\n-------------------\n");
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: Column(
        children: [
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  child: TextFormField(
                    controller: _seachController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: ' Seach location'),
                    onChanged: (value) {
                      print(value);
                    },
                    focusNode: _focus,
                  ),
                ),
                SizedBox(
                    // height: 100,
                    child: ListView.builder(
                        shrinkWrap: true, //높이를 자동으로 해주고 싶을때
                        itemCount: _placeList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () async {
                              // List<Location> locations = await locationFromAddress(_placeList[index]['description']);
                              // print(_placeList[index]['description']);
                              // print(locations.last.latitude);
                              // print(locations.last.longitude);
                              var place = await LocationService()
                                  .getPlace(_placeList[index]['description']);
                              _goToPlace(place);
                              _seachController.text =
                                  _placeList[index]['description'];
                              _placeList.clear();
                            },
                            title: Text(_placeList[index]['description']),
                          );
                        }),
                  ),
                // TextFormField(
                //   controller: _destinationController,
                //   textCapitalization: TextCapitalization.words,
                //   decoration: InputDecoration(hintText: ' Destination'),
                //   onChanged: (value){
                //     print(value);
                //   },
                // ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: () async{
          //     var directions = await LocationService().getDirections(_originController.text, _destinationController.text);
          //     // var place = await LocationService().getPlace(_searchController.text);
          //     // _goToPlace(place);
          //
          //     _goToPlace(directions['start_location']['lat'],directions['start_location']['lng']);
          //     _setMarker(LatLng(directions['end_location']['lat'], directions['end_location']['lng']));
          //     _setPolyline(directions['polyline_decoded']);
          //   },
          //   icon: Icon(Icons.search),),
          Expanded(
            child: GoogleMap(
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              mapType: _currentMapType,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                // setState(() {
                //   polygonLatLngs.add(point);
                //   _setPolygon();
                // });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          // Align(
          //   alignment: Alignment(
          //       Alignment.bottomLeft.x + 0.1, Alignment.bottomLeft.y - 0.05),
          //   child: FloatingActionButton.extended(
          //     onPressed: () async {
          //       Position position = await getUserCurrentLocation();
          //       final GoogleMapController controller = await _controller.future;
          //       controller.animateCamera(CameraUpdate.newCameraPosition(
          //           CameraPosition(
          //               target: LatLng(position.latitude, position.longitude),
          //               zoom: 15)));
          //       _setMarker(LatLng(position.latitude, position.longitude));
          //       // _markers.clear();
          //       // _markers.add(Marker(markerId: const MarkerId('currentLocation'),position: LatLng(position.latitude, position.longitude)));
          //     },
          //     label: const Text('current loacation!'),
          //     icon: const Icon(Icons.location_searching),
          //   ),
          // ),
          Align(
            alignment: Alignment(
                Alignment.bottomLeft.x + 0.1, Alignment.bottomLeft.y - 0.05),
            child: FloatingActionButton(
              onPressed: () async {
                Position position = await getUserCurrentLocation();
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 15)));
                _setMarker(LatLng(position.latitude, position.longitude));
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.location_searching),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: '홈',
            icon: Icon(
              CupertinoIcons.home,
            ),
          ),
          BottomNavigationBarItem(
            label: '리스트',
            icon: Icon(
              CupertinoIcons.list_bullet,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place
      // double lat,
      // double lng,
      ) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;

    var zoomLevel = _getZoomLevel(LatLng(place['geometry']['viewport']['northeast']['lat'], place['geometry']['viewport']['northeast']['lng']),
        LatLng(place['geometry']['viewport']['southwest']['lat'], place['geometry']['viewport']['southwest']['lng']));
    print('zoomLevel: $zoomLevel');

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: await zoomLevel),
      ),
    );
    _setMarker(LatLng(lat, lng));

  }

  Future<double> _getZoomLevel(LatLng ne, LatLng sw){
    var result = LocationService().getDistance(ne, sw);
    return result;
  }

  Future<void> _changeMapType() async {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
}
