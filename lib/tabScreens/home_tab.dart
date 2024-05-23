// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:collective_rider/assistant/assistant_methods.dart';
import 'package:collective_rider/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geolocator = Geolocator();

  LocationPermission? _locationPermission;
  String statusText = 'Now Offline';
  Color buttonColor = Colors.grey;
  bool isRiderActive = false;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateRiderPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    riderCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(riderCurrentPosition!.latitude, riderCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    if (!mounted) return;

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            riderCurrentPosition!, context);
    //print("This is our address =" + humanReadableAddress);
  }

  readCurrentRiderInformation() async {
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineRiderData.id = (snap.snapshot.value as Map)["id"];
        onlineRiderData.name = (snap.snapshot.value as Map)["name"];
        onlineRiderData.phone = (snap.snapshot.value as Map)["phone"];
        onlineRiderData.email = (snap.snapshot.value as Map)["email"];
        onlineRiderData.address = (snap.snapshot.value as Map)["address"];
        onlineRiderData.vehicleColor =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicle_color"];
        onlineRiderData.vehicleModel =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicle_model"];
        onlineRiderData.vehicleNumber =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicle_number"];

        riderVehicleType =
            (snap.snapshot.value as Map)["vehicle_details"]["type"];
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentRiderInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kGooglePlex,
          padding: const EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locateRiderPosition();
          },
        ),

        // UI for online/offline Rider
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),

        // Button for online/offline rider
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isRiderActive != true) {
                    riderIsOnlineNow();
                    updateRidersLocationAtRealTime();
                    setState(() {
                      statusText = "Now Online";
                      isRiderActive = true;
                      buttonColor = Colors.transparent;
                    });
                  } else {
                    riderIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isRiderActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: "You are offline now.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  riderIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    riderCurrentPosition = pos;

    Geofire.initialize("activeRiders");
    Geofire.setLocation(
      currentUser!.uid,
      riderCurrentPosition!.latitude,
      riderCurrentPosition!.longitude,
    );

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.set("idle");
    ref.onValue.listen((event) {});
  }

  updateRidersLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isRiderActive == true) {
        Geofire.setLocation(currentUser!.uid, riderCurrentPosition!.latitude,
            riderCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
          riderCurrentPosition!.latitude, riderCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  riderIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}
