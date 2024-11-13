import 'dart:convert';

import 'package:aligntracker/auth/login.dart';
import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/homeNav/Home.dart';
import 'package:aligntracker/pages/homeNav/Leaderboard.dart';
import 'package:aligntracker/pages/homeNav/Profile.dart';
import 'package:aligntracker/pages/user/profile.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? profilePic;

  List<Widget> pages = [Home(), Leaderboard(), Profile()];
  int _currentPage = 0;
  int _selectedIndex = 0;

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
          profilePic = '$serverURL/api${responseBody['profilePic']}';
        });
      }
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDetails(context);
  }

  void showToast(String message, bool success) {
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      builder: (context) => ToastCard(
        leading: Icon(
          success ? Icons.check_circle : Icons.flutter_dash,
          size: 28,
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: GNav(
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
          title: const Text("Home page"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20.0), // Adjust the radius as needed
                  child: profilePic == null
                      ? Image.asset(
                          "assets/images/blankpfp.jpg",
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          profilePic!,
                          fit: BoxFit.cover,
                        ),
                ))
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
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () => _logout(context),
                        child: const Text("Logout")),
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
              ListTile(
                title: const Text('School'),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
            ],
          ),
        ),
        body: pages[_currentPage]);
  }
}
