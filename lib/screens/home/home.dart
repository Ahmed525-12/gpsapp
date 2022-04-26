import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "homeScreen";
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.4918159, 39.5924081),
    zoom: 14.4746,
  );

  static final CameraPosition homes = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(24.4907035, 39.5954688),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    getUserLocation();
    var userMarker = Marker(
        markerId: MarkerId("user_location"),
        position: LatLng(locationData?.latitude ?? 24.4907035,
            locationData?.longitude ?? 39.5954688));
    markers.add(userMarker);
    print(locationData?.longitude);
    print(
        "---------------------------------------------------------------------------------------------");
    print(locationData?.latitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google"),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the Home !'),
        icon: Icon(Icons.home),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(homes));
  }

  Location location = new Location();

  PermissionStatus? prmitionStatus = null;

  bool serviceEnabled = false;

  LocationData? locationData = null;

  void getUserLocation() async {
    bool premGranted = await isPremsioinGranted();
    if (!premGranted) return;
    bool gpsEnabled = await isServiceEnabled();
    if (!gpsEnabled) return;

    locationData = await location.getLocation();

    print("longtude ${locationData?.longitude}");
    print("latitude ${locationData?.latitude}");
    location.onLocationChanged.listen((event) {
      locationData = event;
      updatemarker();
      print("longtude ${locationData?.longitude}");
      print("latitude ${locationData?.latitude}");
    });
  }

  void updatemarker() async{
    var userMarker = Marker(
        markerId: MarkerId("user_location"),
        position: LatLng(locationData?.latitude ?? 24.4907035,
            locationData?.longitude ?? 39.5954688));
    markers.add(userMarker);
    var newCamrerapos = CameraPosition(zoom: 19,
        target: LatLng(locationData?.latitude ?? 24.4907035,
            locationData?.longitude ?? 39.5954688));
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newCamrerapos));
    setState(() {});
  }

  Future<bool> isPremsioinGranted() async {
    prmitionStatus = await location.hasPermission();
    if (prmitionStatus == PermissionStatus.denied) {
      prmitionStatus = await location.requestPermission();
    }
    return prmitionStatus == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }
}
