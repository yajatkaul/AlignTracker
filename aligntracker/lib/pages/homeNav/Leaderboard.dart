import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
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
      setState(() {
        leaderboard.addAll(data['users']);
        hasMore = data['hasMore'];
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
      setState(() {
        user = jsonDecode(response.body);
      });
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false);
    }
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
        child: Stack(
          children: [
            leaderboard.isEmpty
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
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
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
            if (user != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20.0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                image: NetworkImage(
                                    '$serverURL/api${user!['profilePic']}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(user!['displayName']),
                        ],
                      ),
                      Text(user!['points'].toString())
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
