import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mymap/network/rest_client.dart';
import 'package:mymap/screen/google_map/location_service.dart';
import 'package:label_marker/label_marker.dart';

class MapFacility extends StatefulWidget {
  @override
  State<MapFacility> createState() => MapFacilityState();
}

class MapFacilityState extends State<MapFacility> {
  Completer<GoogleMapController> _controller = Completer();

  // TextEditingController _originController = TextEditingController();
  // TextEditingController _destinationController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  FocusNode _focus = FocusNode();
  List<dynamic> _placeList = [];

  Set<Marker> _markers = Set<Marker>();
  Set<Marker> _labelMarkers = Set<Marker>();

  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  Set<Polyline> _polylines = Set<Polyline>();
  MapType _currentMapType = MapType.normal;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  int _markerCounter = 1;

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/radioStation.png")
        .then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });
  }

  static const CameraPosition _kKTHyeHwa = CameraPosition(
    target: LatLng(37.57717998520996, 127.00154591255578),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _setMarker(LatLng(37.57717998520996, 127.00154591255578), "KT혜화지사");
    _searchController.addListener(() {
      if (_focus.hasFocus) onChange();
    });
    getrsList();
    addCustomIcon();
  }

  void onChange() async {
    // _placeList = await LocationService().getSuggestion(_searchController.text);

    if (_searchController.text == "") {
      setState(() {
        _placeList.clear();
      });
    } else {
      var response = await getSuggestion(_searchController.text);
      setState(() {
        _placeList = response;
        print(_placeList);
      });
    }
  }

  Future<void> getrsList() async {
    late RestClient client;
    Dio dio = Dio();
    client = RestClient(dio);
    final response = await client.getRadioStationList("강북");
    // print(response.returnCode);
    // print(response.data);
    response.data.forEach((d) {
      // print(d["LATITUDE"]);
      _setMarker(
          LatLng(double.parse(d["LATITUDE"]), double.parse(d["LONGITUDE"])),
          d["EQUIP_ID"]);
    });
  }

  Future<List<dynamic>> getSuggestion(String search_word) async {
    late RestClient client;
    Dio dio = Dio();
    client = RestClient(dio);
    final response = await client.getSuggestion(search_word);
    // print(response.returnCode);
    // print(response.data);
    return response.data;
  }

  void _setMarker(LatLng point, String label) {
    setState(() {
      // _markers.add(
      //   Marker(
      //     markerId: MarkerId('marker' + _markerCounter.toString()),
      //     position: point,
      //     icon: markerIcon,
      //     onTap: () => {
      //       print("clicked"),
      //     },
      //   ),
      // );
      _markers.addLabelMarker(LabelMarker(
        label: label,
        markerId: MarkerId('marker' + _markerCounter.toString()),
        position: point,
        onTap: () => {
          print("clicked"),
        },
        textStyle: TextStyle(
          fontSize: 15,
          color: Colors.black,
          letterSpacing: 1.0,
          fontFamily: 'Roboto Bold',
        ),
        backgroundColor: Colors.blueAccent,
        alpha: 0.7,
        icon: markerIcon,
      ));
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
                    controller: _searchController,
                    // textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: ' Search location'),
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
                            setState(() {
                              _focus.unfocus();
                              _goToPlace(place);
                              _searchController.text =
                                  _placeList[index]['description'];
                              _placeList.clear();
                            });
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
              markers: (_markers),
              polygons: _polygons,
              polylines: _polylines,
              mapType: _currentMapType,
              initialCameraPosition: _kKTHyeHwa,
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
                _setMarker(
                    LatLng(position.latitude, position.longitude), "현재 위치");
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

    var zoomLevel = _getZoomLevel(
        LatLng(place['geometry']['viewport']['northeast']['lat'],
            place['geometry']['viewport']['northeast']['lng']),
        LatLng(place['geometry']['viewport']['southwest']['lat'],
            place['geometry']['viewport']['southwest']['lng']));
    print('zoomLevel: $zoomLevel');

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: await zoomLevel),
      ),
    );
    _setMarker(LatLng(lat, lng), "");
  }

  Future<double> _getZoomLevel(LatLng ne, LatLng sw) {
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
