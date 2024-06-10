import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/infoHandler/app_info.dart';
import 'package:collective_rider/screens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsTabScreen extends StatefulWidget {
  const EarningsTabScreen({super.key});

  @override
  State<EarningsTabScreen> createState() => _EarningsTabScreenState();
}

class _EarningsTabScreenState extends State<EarningsTabScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color: darkTheme ? Colors.amberAccent : Colors.lightBlueAccent,
      child: Column(
        children: [
          //earnings
          Container(
            color: darkTheme ? Colors.black : Colors.lightBlue,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "Your Earnings",
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    " " +
                        Provider.of<AppInfo>(context, listen: false)
                            .riderTotalEarnings,
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // total number of trips
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const TripsHistoryScreen()));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white54,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Image.asset(
                    onlineRiderData.vehicleType == "Bike"
                        ? "assets/images/bike.png"
                        : "assets/images/car.png",
                    scale: 2,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Trips Completed",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      Provider.of<AppInfo>(context, listen: false)
                          .allTripsHistoryInformationList
                          .length
                          .toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
