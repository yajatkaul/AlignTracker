import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/SitePage.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
      Uri.parse('$serverURL/api/tracking/getSites?completed=false'),
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

  @override
  void initState() {
    super.initState();
    _getSites();
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
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SitePage(site: site),
                            ),
                          );
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
                                  ),
                                  Text(
                                    site['siteName'] ?? 'No Title',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                              Text(site['timing'],
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
