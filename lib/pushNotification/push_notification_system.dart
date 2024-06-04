import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/models/user_ride_request_information.dart';
import 'package:collective_rider/pushNotification/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1. Termintaed
    // When the app is closed and opened directly fromt the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });

    //2. Foreground
    // When the app is open and receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });

    //3. Background
    // When the app is in the background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .child("riderId")
        .onValue
        .listen((event) {
      if (event.snapshot.value == "waiting" ||
          event.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(userRideRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            double originLat = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["latitude"]);
            double originLng = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["longitude"]);
            String originAddress =
                (snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["latitude"]);
            double destinationLng = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["longitude"]);
            String destinationAddress =
                (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails =
                UserRideRequestInformation();

            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;
            userRideRequestDetails.destinationLatLng =
                LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress = destinationAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox());
          } else {
            Fluttertoast.showToast(msg: "This Ride Request Id do not exist.");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled.");
        Navigator.pop(context);
      }
    });
  }
}
