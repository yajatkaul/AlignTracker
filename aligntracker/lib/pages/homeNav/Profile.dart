import 'dart:convert';
import 'package:aligntracker/auth/login.dart';
import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/planPage/PlanPage.dart';
import 'package:aligntracker/pages/sitePage/FinishedSites.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String? profilePic;
  String? name;
  String? points;
  String? employeeId;

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
          name = responseBody['displayName'];
          points = responseBody['points'].toString();
          employeeId = responseBody['_id'];
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
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(25.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: profilePic == null
                                  ? const AssetImage(
                                      "assets/images/blankpfp.jpg")
                                  : NetworkImage(profilePic!),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        name ?? "Name",
                        softWrap: true,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
                Text(points ?? "Points")
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Finishedsites()));
                    },
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                    child: const Text(
                      "Previous Sites",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                    onPressed: () async {
                      _logout(context);
                    },
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 60,
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Planpage()));
              },
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
              child: const Text(
                "Todays Plan",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(fontSize: 18),
              )),
        )
      ]),
    ));
  }
}
