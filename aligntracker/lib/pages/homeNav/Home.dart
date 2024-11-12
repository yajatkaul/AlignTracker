import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/SitePage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> sites = [];
  Future<void> _getSites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/tracking/getSites'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        sites = jsonDecode(response.body);
      });
    } else {}
  }

  void checkPerms() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSites();
    checkPerms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sites.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: sites.map((site) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SitePage(site: site),
                        ),
                      );
                    },
                    title: Text(site['siteName'] ?? 'No Title'),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
