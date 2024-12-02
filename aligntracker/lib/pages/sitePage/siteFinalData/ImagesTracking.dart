import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/planPage/SnagDetials.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Imagestracking extends StatefulWidget {
  final String siteId;
  const Imagestracking({super.key, required this.siteId});

  @override
  State<Imagestracking> createState() => _ImagestrackingState();
}

class _ImagestrackingState extends State<Imagestracking> {
  bool loaded = false;
  List<dynamic> siteImages = [];
  List<dynamic> locations = [];
  List<dynamic> locationStatus = [];
  List<dynamic> selfi = [];

  Future<void> _getSites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse(
          '$serverURL/api/tracking/getspecificTracking?siteID=${widget.siteId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          final responseBody = jsonDecode(response.body);
          loaded = true;
          siteImages = responseBody['siteImages'];
          selfi.add(responseBody['selfi']);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const Text(
              "Site Images",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 470,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                children: siteImages.map((image) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeableImageGallery(
                            images: siteImages,
                            initialIndex: siteImages.indexOf(image),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      '$serverURL/api/$image',
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Text(
              "Installer Images",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 470,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                children: selfi.map((image) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeableImageGallery(
                            images: selfi,
                            initialIndex: selfi.indexOf(image),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      '$serverURL/api/$image',
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
