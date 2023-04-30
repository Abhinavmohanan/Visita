import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:visita/constants.dart';
import 'package:visita/model/user.dart';
import 'package:visita/pages/home_page.dart';
import 'package:visita/pages/host_detail.dart';
import 'package:visita/pages/social_page.dart';
import 'package:visita/pages/uploadImage.dart';
import 'package:visita/services/helper.dart';
import 'package:visita/ui/auth/authentication_bloc.dart';
import 'package:visita/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:visita/theme/colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:visita/pages/map_page.dart';
import 'package:visita/pages/profile_page.dart';
// import 'package:travel_app/pages/social_page.dart';

import 'dart:math' as math;

import 'package:visita/pages/home_page.dart';

// import 'package:visita/theme/colors.dart';

class RootApp extends StatefulWidget {
  final User user;

  const RootApp({Key? key, required this.user}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  late User user;
  String? metaMaskaddress;

  setMetaAddress(String meta) {
    setState(() {
      metaMaskaddress = meta;
    });
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  int activeTab = 0;
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        bottomNavigationBar: getFooter(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: getFloatingButton(),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: activeTab,
      children: [
        HomePage(),
        SocialPage(),
        Center(
          child: Text("Upload"),
        ),
        GetHost(),
        ProfilePage(setMetaAddress: setMetaAddress),
      ],
    );
  }

  Widget getFooter() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 20,
              offset: Offset(0, 1)),
        ],
        borderRadius: BorderRadius.circular(20),
        color: white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = 0;
                    });
                  },
                  child: Icon(
                    Feather.home,
                    size: 25,
                    color: activeTab == 0 ? primary : black,
                  ),
                ),
                SizedBox(
                  width: 55,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = 1;
                    });
                  },
                  child: Icon(
                    Icons.people_alt,
                    size: 25,
                    color: activeTab == 1 ? primary : black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = 3;
                    });
                  },
                  child: Icon(
                    Icons.map,
                    size: 25,
                    color: activeTab == 3 ? primary : black,
                  ),
                ),
                SizedBox(
                  width: 55,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = 4;
                      // context.read<AuthenticationBloc>().add(LogoutEvent());
                    });
                  },
                  child: Icon(
                    MaterialIcons.account_circle,
                    size: 28,
                    color: activeTab == 4 ? primary : black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getFloatingButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ImageUpload(
                    metaMaskaddress: metaMaskaddress,
                  )));
        });
      },
      child: Transform.rotate(
        angle: -math.pi / 4,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 1)),
          ], color: black, borderRadius: BorderRadius.circular(23)),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Center(
                child: Icon(
              Ionicons.md_add_circle_outline,
              color: white,
              size: 26,
            )),
          ),
        ),
      ),
    );
  }
}
