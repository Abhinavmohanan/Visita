import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({Key? key}) : super(key: key);

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  Placemark? location;
  var servicestatus, permission, haspermission;

  @override
  void initState() {
    getLatlong();
  }

  getLatlong() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  getLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      location = placemarks[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset(
              'assets/map.png',
              width: 100,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Location",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  location == null
                      ? "Fetching your location...."
                      : "${location?.locality ?? ""}, ${location?.administrativeArea ?? ""}, ${location?.country}",
                  style: Theme.of(context).textTheme.labelLarge,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
