import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:visita/model/recommended_places_model.dart';
import 'package:http/http.dart' as http;
import 'package:visita/pages/tourist_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendedPlaces extends StatefulWidget {
  const RecommendedPlaces({Key? key}) : super(key: key);

  @override
  State<RecommendedPlaces> createState() => _RecommendedPlacesState();
}

class _RecommendedPlacesState extends State<RecommendedPlaces> {
  var recommended;
  @override
  void initState() {
    fetchRecommended();
  }

  fetchRecommended() async {
    var resp = await http
        .get(Uri.parse("https://visita-api.onrender.com/api/v1/home"));
    recommended = jsonDecode(resp.body)["data"]["recommendations"];
    print(recommended);
    setState(() {
      recommended = recommended?.map<RecommendedPlaceModel>((e) {
        return RecommendedPlaceModel(
            image: "assets/Recomendations_Images/${e["image"]}",
            rating: e["rating"].toDouble(),
            name: e["name"],
            location: e["location"]);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return recommended == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SizedBox(
            height: 235,
            child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 220,
                    child: Card(
                      elevation: 0.4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => TouristDetailsPage(
                          //         image: recommended[index].image,
                          //       ),
                          //     ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  recommended[index].image,
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                  height: 150,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    //name of the tourist attraction
                                    recommended[index].name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade700,
                                    size: 14,
                                  ),
                                  const Text(
                                    "4.4",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.location,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    recommended[index].location,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                itemCount: recommended.length),
          );
  }
}
