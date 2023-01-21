//main.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screen/google_map/map_sample.dart';
import 'screen/google_map/map_facility.dart';


// import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      // home: MapSample(),
      home: MapFacility(),
    );
  }
}
