//main.dart

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mymap/location_service.dart';

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
  TextEditingController _searchController = TextEditingController();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(37.42796133580664, -122.085749655962),
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414
  );
  static final Marker _kLakeMaker = Marker(
    markerId: MarkerId('_kLake'),
    infoWindow: InfoWindow(title: 'Lake'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: LatLng(37.43296265331129, -122.08832357078792),
  );

  Set<Marker> markers = {};
  MapType _currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Map'),),
      body: Column(
        children: [
          Row(children: [
            Expanded(child: TextFormField(
              controller: _searchController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: 'Search by City'),
              onChanged: (value){
                print(value);
              },
            ),),
            IconButton(
              onPressed: () async{
                var place = await LocationService().getPlace(_searchController.text);
                _goToPlace(place);
              },
              icon: Icon(Icons.search),),
          ],),
          Expanded(
            child: GoogleMap(
              markers: {
                _kGooglePlexMarker,
                _kLakeMaker,
              },
              // mapType: MapType.normal,
              mapType: _currentMapType,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(
              Alignment.topRight.x, Alignment.topRight.y +0.3
            ),
            child: FloatingActionButton.extended(
              onPressed: _changeMapType,
              label: const Text('layer'),
              icon: const Icon(Icons.map),
            ),
          ),Align(
            alignment: Alignment(
                Alignment.topRight.x, Alignment.topRight.y +0.4
            ),
            child: FloatingActionButton.extended(
              onPressed: _goToTheLake,
              label: const Text('To the lake!'),
              icon: const Icon(Icons.radar),
            ),
          ),
          Align(
            alignment: Alignment(
                Alignment.topRight.x, Alignment.topRight.y +0.5
            ),
            child: FloatingActionButton.extended(
              onPressed: () async{
                Position position = await getUserCurrentLocation();
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: LatLng(position.latitude, position.longitude), zoom:15)
                ));
                markers.clear();
                markers.add(Marker(markerId: const MarkerId('currentLocation'),position: LatLng(position.latitude, position.longitude)));
              },
              label: const Text('current loacation!'),
              icon: const Icon(Icons.location_searching),
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

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );
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
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
}

