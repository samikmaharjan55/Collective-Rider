import 'dart:async';

import 'package:collective_rider/assistant/assistant_methods.dart';
import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/models/user_ride_request_information.dart';
import 'package:collective_rider/splashScreen/splash_screen.dart';
import 'package:collective_rider/widgets/fare_amount_collection_dialog.dart';
import 'package:collective_rider/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails, super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircles = Set<Circle>();
  Set<Polyline> setOfPolylines = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineRiderCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  //Step 1: When rider accepts the user ride request
  // originLatLng = riderCurrentLocation
  // destinationLatLng = userPickUpLocation

  // Step 2: When rider picks up the user
  // originLatLng = userCurrentLocation which will be the current location of the rider at that time
  // destinationLatLng = userDropOffLocation

  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);
    polylinePositionCoordinates.clear();
    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    setOfPolylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      setOfPolylines.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }
    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });
  }

  @override
  void initState() {
    super.initState();
    saveAssignedRiderDetailsToUserRideRequest();
  }

  getRidersLocationUpdatesAtRealTime() {
    LatLng oldLatLng = const LatLng(0, 0);

    streamSubscriptionRiderLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      riderCurrentPosition = position;
      onlineRiderCurrentPosition = position;
      LatLng latLngLiveRiderPosition = LatLng(
        onlineRiderCurrentPosition!.latitude,
        onlineRiderCurrentPosition!.longitude,
      );
      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveRiderPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your position"),
      );
      setState(() {
        CameraPosition cameraPosition = CameraPosition(
          target: latLngLiveRiderPosition,
          zoom: 18,
        );
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveRiderPosition;
      updateDurationTimeAtRealTime();

      // updating rider location at real time in database
      Map riderLatLngDataMap = {
        "latitude": onlineRiderCurrentPosition!.latitude.toString(),
        "longitude": onlineRiderCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("riderLocation")
          .set(riderLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;
      if (onlineRiderCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(onlineRiderCurrentPosition!.latitude,
          onlineRiderCurrentPosition!.longitude);

      var destinationLatLng;
      if (rideRequestStatus == "accepted") {
        destinationLatLng =
            widget.userRideRequestDetails!.originLatLng; // user pickup location
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);
      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;
    }
  }

  createRiderIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: const Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/bike.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedRiderDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map riderLocationDataMap = {
      "latitude": riderCurrentPosition!.latitude.toString(),
      "longitude": riderCurrentPosition!.longitude.toString(),
    };
    if (databaseReference.child("riderId") != "waiting") {
      databaseReference.child("riderLocation").set(riderLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("riderId").set(onlineRiderData.id);
      databaseReference.child("riderName").set(onlineRiderData.name);
      databaseReference.child("riderPhone").set(onlineRiderData.phone);
      databaseReference.child("ratings").set(onlineRiderData.ratings);
      databaseReference.child("vechicleDetails").set(
          "${onlineRiderData.vehicleModel} ${onlineRiderData.vehicleNumber} (${onlineRiderData.vehicleColor}) ");
      saveRideRequestIdToRiderHistory();
    } else {
      Fluttertoast.showToast(
          msg:
              "This ride is already accepted by another rider. \n Reloading the App");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const SplashScreen()));
    }
  }

  saveRideRequestIdToRiderHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    // get the tripDirectionDetails = distance travelled
    var currentRiderPositionLatLng = LatLng(
        onlineRiderCurrentPosition!.latitude,
        onlineRiderCurrentPosition!.longitude);
    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentRiderPositionLatLng,
            widget.userRideRequestDetails!.originLatLng!);

    // fare amount
    double totalFareAmount =
        AssistantMethods.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails);

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set("ended");

    Navigator.pop(context);

    // display fare amount in dialog box

    showDialog(
      context: context,
      builder: (BuildContext context) => FareAmountCollectionDialog(
        totalFareAmount: totalFareAmount,
      ),
    );

    // save fare amount to rider total earnings
    saveFareAmountToRiderEarnings(totalFareAmount);
  }

  saveFareAmountToRiderEarnings(totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double riderTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("riders")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(riderTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("riders")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: setOfPolylines,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;
              setState(() {
                mapPadding = 350;
              });

              var riderCurrentLatLng = LatLng(riderCurrentPosition!.latitude,
                  riderCurrentPosition!.longitude);

              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolylineFromOriginToDestination(
                  riderCurrentLatLng, userPickUpLatLng!, darkTheme);
              getRidersLocationUpdatesAtRealTime();
            },
          ),

          // UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // duration
                      Text(
                        durationFromOriginToDestination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              darkTheme ? Colors.amber.shade400 : Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.phone,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "images/origin.png",
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              widget.userRideRequestDetails!.originAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme
                                    ? Colors.amberAccent
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "images/destination.png",
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              widget
                                  .userRideRequestDetails!.destinationAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme
                                    ? Colors.amberAccent
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Rider has arrived at user pickup location - Arrived Button
                          if (rideRequestStatus == "accepted") {
                            rideRequestStatus = "arrived";
                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Request")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "Let's Go";
                              buttonColor = Colors.lightGreen;
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => ProgressDialog(
                                message: "Loading...",
                              ),
                            );
                            await drawPolylineFromOriginToDestination(
                              widget.userRideRequestDetails!.originLatLng!,
                              widget.userRideRequestDetails!.destinationLatLng!,
                              darkTheme,
                            );
                            Navigator.pop(context);
                          }
                          // User has been picked from the user's current location = Let's Go Button
                          else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "ontrip";
                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Request")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "End Trip";
                              buttonColor = Colors.redAccent;
                            });
                          }

                          // User and Rider has reached the drop-off location - End Trip Button
                          else if (rideRequestStatus == "ontrip") {
                            endTripNow();
                          }
                        },
                        icon: Icon(
                          Icons.directions_bike,
                          color: darkTheme ? Colors.black : Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: TextStyle(
                            color: darkTheme ? Colors.black : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
