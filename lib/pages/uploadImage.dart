import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visita/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:visita/ui/loading_cubit.dart';

class ImageUpload extends StatefulWidget {
  String? metaMaskaddress;
  ImageUpload({super.key, this.metaMaskaddress});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  XFile? imageFile;
  TextEditingController location = TextEditingController();

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final ImagePicker picker = ImagePicker();
      print("CApturing");
      imageFile = await picker.pickImage(source: imageSource);
      setState(() {
        imageFile = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadImage(XFile? image) async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      print("Uploading Image");
      var response = await http.post(
          Uri.parse("https://visita-api.onrender.com/api/v1/posts/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id": firebaseUser!.uid,
            "text": location.text,
            "postedBy": firebaseUser.displayName
          }));
      print(response.body);
      String id = jsonDecode(response.body)['_id'];
      // final response3 = await Dio().post(
      //   "http://192.168.137.1:4567/api/v1/posts/$id",
      //   data: formData,
      // );

      // print("Sending second request");

      // if (response3.statusCode == 200) {
      //   var map = response3.data as Map;
      //   print('success');
      //   print(map);
      // }

      // String id = jsonDecode(response.body)['_id'];
      print("Sending second resp");

      var request = http.MultipartRequest("POST",
          Uri.parse("https://visita-api.onrender.com/api/v1/posts/$id"));
      request.files.add(http.MultipartFile.fromBytes(
          'image', File(imageFile!.path).readAsBytesSync(),
          filename: imageFile!.path));
      request.fields['userURL'] = firebaseUser.photoURL!;
      var res = await request.send();
      final respStr = await res.stream.bytesToString();
      print(widget.metaMaskaddress);
      if (widget.metaMaskaddress != null) {
        MintNFT();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> MintNFT() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.verbwire.com/v1/nft/mint/quickMintFromFile'),
    );
    request.headers.addAll({
      'X-API-Key': 'sk_live_9b032456-fb02-4ae3-928e-169e2f69e470',
      'accept': 'application/json',
      'content-type': 'multipart/form-data',
    });
    request.fields.addAll({
      'allowPlatformToOperateToken': 'true',
      'chain': 'mumbai',
      'name': location.text,
      'description': ' ',
      'recipientAddress': '0x1c0e49bb411075bbfea5e954b6b870dc66b4c80f',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'filePath',
      imageFile!.path,
    ));
    var response = await request.send();
    print("Mint Response");
    print(await response.stream.bytesToString());
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(File(imageFile!.path));
    } else {
      return Text('Upload an Image', style: TextStyle(fontSize: 18.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Upload",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildImage())),
          Container(
            margin: EdgeInsets.only(top: 50, bottom: 50, left: 34, right: 34),
            child: TextField(
              style:
                  TextStyle(fontSize: 13.0, height: 1.0, color: Colors.black),
              decoration: new InputDecoration(
                labelText: "Enter Location",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(15.0),
                  borderSide: new BorderSide(),
                ),
                //fillColor: Colors.green
              ),
              controller: location,
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: imageFile != null
                ? <Widget>[
                    _buildActionButton(
                      key: Key('submit'),
                      text: 'Upload',
                      onPressed: () async {
                        if (location.text.isEmpty) {
                          SnackBar s = const SnackBar(
                              content: Text("Please enter the location"));
                          ScaffoldMessenger.of(context).showSnackBar(s);
                          return;
                        }
                        Navigator.pop(context);
                        await uploadImage(imageFile);
                      },
                    ),
                    _buildActionButton(
                      key: Key('delete'),
                      text: 'Retake',
                      onPressed: () => setState(() {
                        imageFile = null;
                      }),
                    ),
                  ]
                : <Widget>[
                    _buildActionButton(
                      key: Key('retake'),
                      text: 'Photos',
                      onPressed: () => captureImage(ImageSource.gallery),
                    ),
                    _buildActionButton(
                      key: Key('upload'),
                      text: 'Camera',
                      onPressed: () => captureImage(ImageSource.camera),
                    ),
                  ]));
  }

  Widget _buildActionButton(
      {required Key key, required String text, required Function onPressed}) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: ElevatedButton(
          key: key,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Container(
              padding: EdgeInsets.all(13),
              child: Text(text,
                  style: TextStyle(fontSize: 15.0, color: Colors.white))),
          onPressed: () => onPressed()),
    );
  }
}
