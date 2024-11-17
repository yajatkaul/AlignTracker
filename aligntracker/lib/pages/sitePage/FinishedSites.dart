import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/siteFinalData/page.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Finishedsites extends StatefulWidget {
  const Finishedsites({super.key});

  @override
  State<Finishedsites> createState() => _FinishedsitesState();
}

class _FinishedsitesState extends State<Finishedsites> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  List<dynamic> sites = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _getSites() async {
    if (isLoading || !hasMore) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse(
          '$serverURL/api/tracking/getSites?completed=true&page=$currentPage&limit=14'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (mounted) {
        setState(() {
          sites.addAll(data['sites']);
          hasMore = data['hasMore'];
          currentPage++;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getSites();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _getSites();
          print("Called");
        }
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        currentPage = 1;
        hasMore = true;
        sites = [];
      });
    }
    await _getSites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finished Sites"),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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
                            width: 160,
                            child: Text(
                              site['siteName'] ?? 'No Title',
                              softWrap: true,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const Icon(Icons.check)
                        ],
                      ),
                      Text(site['timing'],
                          style: const TextStyle(fontSize: 15)),
                    ],
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
