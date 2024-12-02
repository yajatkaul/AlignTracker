import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/siteFinalData/FinalSitePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiteSelection extends StatefulWidget {
  final String siteId;
  const SiteSelection({super.key, required this.siteId});

  @override
  State<SiteSelection> createState() => _SiteSelectionState();
}

class _SiteSelectionState extends State<SiteSelection> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  List<dynamic> trackings = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> getTracking() async {
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
          '$serverURL/api/tracking/getTracking?siteID=${widget.siteId}&page=$currentPage&limit=14'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          trackings.addAll(data['trackingData']);
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
    getTracking();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          getTracking();
        }
      }
    });
  }

  List<String> splitter(String startTime) {
    List<String> parts = startTime.split(' ');
    return parts;
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        currentPage = 1;
        hasMore = true;
        trackings = [];
      });
    }
    await getTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Tracking"),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: ListView(
          children: trackings.map((tracking) {
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
                          builder: (context) => FinalSitePage(
                                siteId: tracking['siteID']['_id'],
                              )));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        '$serverURL/api${tracking['userID']['profilePic']}'))),
                          ),
                          const SizedBox(
                            width: 10,
                            height: 70,
                          ),
                          SizedBox(
                            width: 160,
                            child: Text(
                              tracking['userID']['displayName'],
                              softWrap: true,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          Text(splitter(tracking['startTime'])[0])
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            ;
          }).toList(),
        ),
      ),
    );
  }
}
