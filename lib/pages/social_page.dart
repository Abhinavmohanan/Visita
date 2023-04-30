import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visita/data/user_json.dart';
import 'package:visita/theme/colors.dart';
import 'package:http/http.dart' as http;

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  var postsList;
  @override
  void initState() {
    fetchPosts();
    print("Fetched");
    super.initState();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    fetchPosts();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) _refreshController.loadComplete();
  }

//To fetch post from API
  fetchPosts() async {
    var response = await http
        .get(Uri.parse("https://visita-api.onrender.com/api/v1/posts/"));
    var posts = jsonDecode(response.body);
    setState(() {
      print(posts["posts"]);
      postsList = posts["posts"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar:
          PreferredSize(child: getAppBar(), preferredSize: Size.fromHeight(60)),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: white,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "What's happening?",
              style: TextStyle(
                  fontSize: 18, color: black, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Feather.bell,
                  color: black,
                  size: 25,
                ))
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(builder: (context, mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("pull up load");
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed!Click retry!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("release to load more");
        } else {
          body = Text("No more Data");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      }),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      controller: _refreshController,
      child: postsList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Feed",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // story profile
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: List.generate(postsList.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 288,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: grey.withOpacity(0.4),
                                          spreadRadius: 2,
                                          blurRadius: 15,
                                          offset: Offset(0, 1))
                                    ],
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            postsList[index]['imageURL']),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              Container(
                                  width: double.infinity,
                                  height: 288,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: black.withOpacity(0.25))),
                              Container(
                                width: double.infinity,
                                height: 288,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    postsList[index]
                                                            ['userURL'] ??
                                                        "https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg"),
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    postsList[index]
                                                        ['postedBy'],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: white),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    postsList[index]['text'],
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: white
                                                            .withOpacity(0.8)),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Icon(
                                            Entypo.dots_three_vertical,
                                            color: white,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
