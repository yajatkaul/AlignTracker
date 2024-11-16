import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/siteFinalData/page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Adminsiteview extends StatefulWidget {
  const Adminsiteview({super.key});

  @override
  State<Adminsiteview> createState() => _AdminsiteviewState();
}

class _AdminsiteviewState extends State<Adminsiteview> {
  bool loaded = false;
  List<dynamic> sites = [];

  Future<void> _getSites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/tracking/admin/trackingData'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          sites = jsonDecode(response.body);
          loaded = true;
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
        title: const Text("Finished Sites"),
      ),
      body: ListView(
        children: sites.map((site) {
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FinalSitePage(siteId: site['_id'])));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 10,
                          height: 70,
                        ),
                        SizedBox(
                          width: 130,
                          child: Text(
                            site['siteName'] ?? 'No Title',
                            softWrap: true,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Text(site['employeeName'] ?? "No Name"),
                        const SizedBox(
                          width: 4,
                        ),
                        const Icon(Icons.check)
                      ],
                    ),
                    Text(site['timing'], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
