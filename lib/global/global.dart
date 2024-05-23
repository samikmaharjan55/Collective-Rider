import 'dart:async';
import 'package:collective_rider/models/rider_data.dart';
import 'package:collective_rider/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionRiderLivePosition;

UserModel? userModelCurrentInfo;

Position? riderCurrentPosition;

RiderData onlineRiderData = RiderData();

String? riderVehicleType = "";
