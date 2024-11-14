import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? user;

  List<dynamic> leaderboard = [];

  Future<void> _getLeaderboard() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('$serverURL/api/user/leaderboard?page=$currentPage&limit=15'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          leaderboard.addAll(data['users']);
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

  Future<void> _getDetails() async {
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
      if (mounted) {
        setState(() {
          user = jsonDecode(response.body);
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
    _getLeaderboard();
    _getDetails();

    // ScrollController listener to detect when user scrolls to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _getLeaderboard();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      leaderboard = [];
      hasMore = true;
      currentPage = 1;
    });
    await _getDetails();
    await _getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // Header Row Container
            Container(
              color: Theme.of(context).colorScheme.surface,
              height: 50,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Position",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "User",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Points",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            Expanded(
              child: leaderboard.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: leaderboard.length + 1,
                      itemBuilder: (context, index) {
                        if (index == leaderboard.length) {
                          return isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink();
                        } else {
                          var user = leaderboard[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Container(
                                      margin: const EdgeInsets.all(8.0),
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: user['profilePic'] == null
                                              ? const AssetImage(
                                                  "assets/images/blankpfp.jpg")
                                              : NetworkImage(
                                                  '$serverURL/api${user['profilePic']}',
                                                ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(user['displayName']),
                                  ],
                                ),
                                Text(user['points'].toString()),
                              ],
                            ),
                          );
                        }
                      },
                    ),
            ),

            // User Info Container at the Bottom
            if (user != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: user!['profilePic'] == null
                                  ? const AssetImage(
                                      "assets/images/blankpfp.jpg")
                                  : NetworkImage(
                                      '$serverURL/api${user!['profilePic']}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(user!['displayName']),
                      ],
                    ),
                    Text(user!['points'].toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
