import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(-6.239590, 106.795620), zoom: 14);

  List<Marker> _marker = [];
  final List<Marker> _initialMarkers = <Marker>[
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(-6.239590, 106.795620),
      infoWindow: InfoWindow(title: "My Current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    )
  ];

  loadData() {
    getUserCurrentLocation().then((value) async {
      print("My current location: ${value.latitude}, ${value.longitude}");

      setState(() {
        _marker.clear();
        _marker.add(Marker(
          markerId: MarkerId("current_location"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(title: "My current location"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ));
      });

      CameraPosition cameraPosition = CameraPosition(
          zoom: 16, target: LatLng(value.latitude, value.longitude));

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error: " + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(_marker),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        padding: EdgeInsets.only(bottom: 100),
        zoomControlsEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadData,
        backgroundColor: Colors.lightBlue,
        icon: Icon(Icons.my_location, color: Colors.white),
        label: Text("Current Location", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
