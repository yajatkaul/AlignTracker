import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/planPage/SnagDetials.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Snagslist extends StatefulWidget {
  final String siteId;
  const Snagslist({super.key, required this.siteId});

  @override
  State<Snagslist> createState() => _SnagslistState();
}

class _SnagslistState extends State<Snagslist> {
  List<dynamic> snags = [];
  bool? loaded = false;

  Future<void> getSnags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/data/getSnags?siteId=${widget.siteId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      if (mounted && responseBody.isNotEmpty) {
        setState(() {
          snags = responseBody;
          loaded = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getSnags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snags List"),
      ),
      body: ListView(
        children: [
          ...snags.map((snag) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SnagDetails(
                                topic: snag['topic'],
                                issue: snag['issue'],
                                images: snag['images'],
                              )));
                },
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 280,
                        child: Text(
                          snag['topic'],
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Row(children: [
                        Icon(snag['status'] == 'Open'
                            ? Icons.check_circle
                            : Icons.cancel),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          snag['status'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ])
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                        height: 90,
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  "$serverURL/api/${snag['images'][0]}")),
                        )),
                  ),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}
