import 'dart:convert';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:visita/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visita/ui/auth/authentication_bloc.dart';

class ProfilePage extends StatefulWidget {
  Function setMetaAddress;
  ProfilePage({Key? key, required this.setMetaAddress}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isPhoto = true;

  var _session, _uri;

  var connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
          name: 'Visita',
          description: 'App to upload NFT travel pictures',
          url: 'https://walletconnect.org',
          icons: [
            'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ]));

  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });
        print(session.accounts[0]);
        widget.setMetaAddress(session.accounts[0]);
        print(session.chainId);
        setState(() {
          _session = session;
        });
      } catch (exp) {
        print(exp);
      }
    } else {
      connector.killSession();
      connector.close();
      setState(() {
        _session = null;
      });
    }
  }

  var mePostList;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  getPosts() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    var response = await http.get(Uri.parse(
        "https://visita-api.onrender.com/api/v1/posts/${firebaseUser?.uid}"));
    setState(() {
      mePostList = jsonDecode(response.body)["posts"];
    });
  }

  @override
  Widget build(BuildContext context) {
    connector.on(
        'connect',
        (session) => setState(
              () {
                _session = _session;
              },
            ));
    connector.on('session_update', (SessionStatus payload) {
      print(payload.accounts[0]);
      print(payload.chainId);
      setState(() {
        _session = payload;
      });
    });
    connector.on(
        'disconnect',
        (payload) => setState(() {
              _session = null;
            }));

    return Scaffold(
      backgroundColor: white,

      //appbar
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
            const Text("Profile"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
        ],
      ),

      // appBar: PreferredSize(
      //     child: getAppBar(), preferredSize: Size.fromHeight(180)),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    return Container(
        padding: EdgeInsets.all(20),
        color: Color.fromARGB(255, 245, 246, 246),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: black)),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                            image: NetworkImage("${firebaseUser!.photoURL}"),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${firebaseUser.displayName}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          getAppBar(),
          SizedBox(
            height: 40,
          ),

          //Connect With Metamask Button
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
            child: ElevatedButton.icon(
              label: Text(
                connector.connected
                    ? 'Disconnect Metamask'
                    : 'Connect Metamask',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              icon: Image.asset(
                'assets/images/metamask.png',
                height: 24,
                width: 24,
              ),
              style: ElevatedButton.styleFrom(
                fixedSize:
                    Size.fromWidth(MediaQuery.of(context).size.width / 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              onPressed: () {
                print("Connecting Metamask");
                loginUsingMetamask(context);
              },
            ),
          ),

          //User Post
          SizedBox(
            height: 40,
            child: Text(
              "Your Post",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          mePostList == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: List.generate(mePostList.length, (index) {
                    return Container(
                      width: (size.width - 60) / 2,
                      height: (size.width - 60) / 2,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: NetworkImage(
                                  mePostList[index]["imageURL"].toString()),
                              fit: BoxFit.cover)),
                    );
                  }),
                )
        ],
      ),
    );
  }
}
