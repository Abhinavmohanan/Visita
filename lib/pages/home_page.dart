import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visita/widgets/location_card.dart';
import 'package:visita/widgets/nearby_places.dart';
import 'package:visita/widgets/recommended_places.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visita/widgets/tourist_places.dart';

//toast message

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: Colors.transparent,

          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Good Morning"),
            Text(
              "${firebaseUser!.displayName}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          // LOCATION CARD
          const LocationCard(),
          const SizedBox(
            height: 15,
          ),
          const TouristPlaces(),
          // CATEGORIES
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommendation",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                  onPressed: () {
                    //To Do
                  },
                  child: const Text("View All"))
            ],
          ),
          const SizedBox(height: 10),
          const RecommendedPlaces(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearby From You",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                  onPressed: () {
                    //To Do
                  },
                  child: const Text("View All"))
            ],
          ),
          const SizedBox(height: 10),
          const NearbyPlaces(),
        ],
      ),
    );
  }
}
