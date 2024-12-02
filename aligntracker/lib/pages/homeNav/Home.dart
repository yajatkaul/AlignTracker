import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/SitePage.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:redacted/redacted.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? activeSiteID;
  bool loaded = false;
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
          sites = jsonDecode(response.body)['sites'];
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

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        loaded = false;
      });
    }

    await _getSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        onRefresh: _handleRefresh,
        child: !loaded
            ? const SiteSkeleton().redacted(context: context, redact: true)
            : sites.isEmpty
                ? ListView()
                : ListView(
                    children: sites.map((site) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 5),
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SitePage(site: site),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      SizedBox(
                                        width: 145,
                                        child: Text(
                                          site['siteName'] ?? 'No Title',
                                          softWrap: true,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                      if (site['started'] == true)
                                        const Icon(Icons.run_circle_rounded)
                                    ],
                                  ),
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

class SiteSkeleton extends StatelessWidget {
  const SiteSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 60,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        )
      ],
    );
  }
}
