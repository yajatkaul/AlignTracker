import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/SitePage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
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
      if (mounted) {
        setState(() {
          sites = jsonDecode(response.body);
        });
      }
    }
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

    final status = await Permission.scheduleExactAlarm.request();
    if (status.isGranted) {
      // You can now set the exact alarm
    } else {
      // Handle the case where permission is denied
      print("Permission denied");
    }
  }

  @override
  void initState() {
    super.initState();
    _getSites();
    checkPerms();
  }

  Future<void> _handleRefresh() async {
    await _getSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: sites.isEmpty
            ? ListView()
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
      ),
    );
  }
}
