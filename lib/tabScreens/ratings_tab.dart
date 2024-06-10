import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/infoHandler/app_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RatingsTabScreen extends StatefulWidget {
  const RatingsTabScreen({super.key});

  @override
  State<RatingsTabScreen> createState() => _RatingsTabScreenState();
}

class _RatingsTabScreenState extends State<RatingsTabScreen> {
  double ratingsNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getRatingsNumber() {
    setState(() {
      ratingsNumber = double.parse(
          Provider.of<AppInfo>(context, listen: false).riderAverageRatings);
    });
    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingsNumber >= 0) {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
    if (ratingsNumber >= 1) {
      setState(() {
        titleStarsRating = "Bad";
      });
    }
    if (ratingsNumber >= 2) {
      setState(() {
        titleStarsRating = "Good";
      });
    }
    if (ratingsNumber >= 3) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    }
    if (ratingsNumber >= 4) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: darkTheme ? Colors.grey : Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              Text(
                "Your Ratings",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: true,
                starCount: 5,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                borderColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                size: 46,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
