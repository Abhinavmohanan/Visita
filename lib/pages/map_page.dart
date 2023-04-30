import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import "package:latlong2/latlong.dart";
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:visita/constants.dart';
import 'package:visita/pages/book_host.dart';
import 'package:visita/pages/host_detail.dart';
import 'package:visita/theme/colors.dart';

class GetHost extends StatefulWidget {
  const GetHost({super.key});

  @override
  State<GetHost> createState() => _GetHostState();
}

class _GetHostState extends State<GetHost> {
  bool servicestatus = false;
  bool haspermission = false;
  MapController mapControl = MapController();
  List<GBSearchData>? data;
  late LocationPermission permission;
  late Position position;
  LatLng? userLoc;
  List<Marker> hostPoints = [];
  int prevval = 0;
  late StreamSubscription<Position> positionStream;
  TextEditingController query = TextEditingController();
  var mapData;

  @override
  void initState() {
    getLatlong();
    getHosts();
    super.initState();
  }

  getHosts() async {
    var res = await http
        .get(Uri.parse("https://visita-api.onrender.com/api/v1/facilities/"));
    print(res.body);
    setState(() {
      mapData = jsonDecode(res.body);
      hostPoints.addAll(mapData.map<Marker>((marker) {
        return (Marker(
            width: 120,
            height: 120,
            point: LatLng(double.parse(mapData[0]["lat"]),
                double.parse(mapData[0]["long"])),
            builder: (ctx) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => HostDetail(
                              mapData: marker,
                            )));
                  },
                  child: Column(children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    Text(marker["hostName"])
                  ]),
                )));
      }));
      print(hostPoints);
    });
  }

  getLocationSearch() async {
    var data2 = await GeocoderBuddy.query(query.text);
    // GBData data2 = await GeocoderBuddy.searchToGBData(data[0]);
    setState(() {
      data = data2;
    });
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
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // hostPoints.add(Marker(
    //     width: 120,
    //     height: 120,
    //     point: LatLng(position.latitude, position.longitude),
    //     builder: (ctx) => GestureDetector(
    //           onTap: () {},
    //           child: Column(children: [
    //             Icon(
    //               Icons.location_on,
    //               color: Colors.red,
    //             ),
    //             Text("You")
    //           ]),
    //         )));

    setState(() {
      userLoc = LatLng(position.latitude, position.longitude);
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        userLoc = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return userLoc == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            floatingActionButton: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      mapControl.move(
                          LatLng(position.latitude, position.longitude), 12);
                    },
                    child: Icon(
                      size: 40,
                      Icons.my_location_outlined,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getHosts();
                    },
                    child: Icon(
                      size: 40,
                      Icons.refresh,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(children: [
              FlutterMap(
                mapController: mapControl,
                options: MapOptions(
                  center: userLoc,
                  zoom: 12,
                ),
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: null,
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: hostPoints,
                  )
                ],
              ),
              Container(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).viewPadding.top + 20),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(17),
                      margin: EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) {
                          if (value.length < prevval) {
                            return;
                          }
                          getLocationSearch();
                        },
                        controller: query,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration.collapsed(
                            hintText: 'Enter location'),
                      ),
                    ),
                    data == null
                        ? Container()
                        : Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(10),
                            height: data!.length * 45,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        userLoc = null;
                                      });
                                      setState(() {
                                        query.text = '';

                                        userLoc = LatLng(
                                            double.parse(data![index].lat),
                                            double.parse(data![index].lon));
                                        mapControl.move(userLoc!, 12);
                                        data = null;
                                      });
                                    },
                                    child: Card(
                                      elevation: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        padding: EdgeInsets.all(17),
                                        margin: EdgeInsets.all(12),
                                        child: Text(data![index].displayName),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: data!.length),
                          )
                  ],
                ),
              )),
            ]),
          );
    ;
  }
}
