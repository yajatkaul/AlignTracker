import 'dart:convert';
import 'dart:io';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profilePic;
  File? galleryPic;
  bool selectedFromGallery = false;

  XFile? image;

  final TextEditingController _usernameController = TextEditingController();

  Future<void> _updateDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final String username = _usernameController.text;

    if (galleryPic != null) {
      uploadImage(File(image!.path), sessionCookie);
    }

    final response = await http.post(
      Uri.parse('$serverURL/api/user/updateUsername'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode(<String, String>{
        'displayName': username,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      showToast(context, responseBody['result'], true);
      Navigator.pop(context);
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(context, responseBody['error'], false);
    }
  }

  Future<void> uploadImage(File image, String? cookie) async {
    final url = Uri.parse('$serverURL/api/user/updatePFP');

    var request = http.MultipartRequest('POST', url);

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.headers['Cookie'] = cookie!;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      ),
    );

    try {
      await request.send();
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
  }

  Future<void> _getDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/user/getUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          responseBody['profilePic'] == null
              ? profilePic = null
              : profilePic = '$serverURL/api${responseBody['profilePic']}';

          _usernameController.text = responseBody['displayName'];
        });
      }
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(context, responseBody['error'], false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _updateDetails(context);
              },
              icon: const Icon(
                Icons.check_circle,
                size: 35,
              ))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    if (mounted) {
                      galleryPic = File(image!.path);
                      selectedFromGallery = true;
                    }
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: profilePic == null && !selectedFromGallery
                    ? Image.asset(
                        "assets/images/blankpfp.jpg",
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                      )
                    : !selectedFromGallery
                        ? Image.network(
                            profilePic!,
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            galleryPic!,
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
