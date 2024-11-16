import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/homeNav/Home.dart';
import 'package:aligntracker/pages/homeNav/Leaderboard.dart';
import 'package:aligntracker/pages/homeNav/Profile.dart';
import 'package:aligntracker/pages/sitePage/AdminSiteView.dart';
import 'package:aligntracker/pages/user/profile.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? profilePic;

  String? role;

  List<Widget> pages = [const Home(), const Leaderboard(), const Profile()];
  int _currentPage = 0;
  int _selectedIndex = 0;

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
          role = responseBody['role'];
        });
      }
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(context, responseBody['error'], false);
    }
  }

  void checkPerms() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog('Location Services Disabled',
          'Please enable location services to use this feature.');
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog('Location Permission Denied',
            'Please allow location permission to continue.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog('Location Permission Permanently Denied',
          'Location permissions are permanently denied. Please enable them in settings.');
      return;
    }

    final status = await Permission.scheduleExactAlarm.request();
    if (status.isGranted) {
      //Someday
    } else {
      print("Permission denied for scheduling exact alarms.");
    }
  }

  void _showLocationDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content:
            const Text('Please turn on location services to start tracking.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkPerms();
    _getDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: GNav(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTabChange: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            gap: 2,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.leaderboard,
                text: "LeaderBoard",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              )
            ]),
        appBar: AppBar(
          toolbarHeight: 60,
          title: const Text("Home page"),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: SizedBox(
                height: 50,
                width: 50,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: profilePic == null
                      ? const AssetImage("assets/images/blankpfp.jpg")
                          as ImageProvider
                      : NetworkImage(profilePic!),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? "assets/images/Logo-Gold.png"
                          : "assets/images/Logo.png",
                      scale: 6,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Home'),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              if (role != null && role == "Admin")
                ListTile(
                  title: const Text('Admin View'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Adminsiteview();
                    }));
                  },
                ),
            ],
          ),
        ),
        body: pages[_currentPage]);
  }
}
