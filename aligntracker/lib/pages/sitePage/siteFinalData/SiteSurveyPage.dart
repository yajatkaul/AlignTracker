import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/planPage/SnagDetials.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class SiteSurveyPage extends StatefulWidget {
  final String siteId;
  const SiteSurveyPage({super.key, required this.siteId});

  @override
  State<SiteSurveyPage> createState() => _SiteSurveyState();
}

class _SiteSurveyState extends State<SiteSurveyPage> {
  Map<String, dynamic> survey = {};
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  Future<void> getSurvey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/data/getSurvey?siteId=${widget.siteId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      if (mounted && jsonDecode(response.body) != null) {
        setState(() {
          survey = jsonDecode(response.body);
          print(survey);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getSurvey();
  }

  @override
  Widget build(BuildContext context) {
    int columns = MediaQuery.of(context).size.width > 600 ? 4 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Site Survey"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          const Text(
            "Documents",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (survey['documents'] != null)
            SizedBox(
              height: 400,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns, // Number of columns in the grid
                  crossAxisSpacing: 10, // Spacing between columns
                  mainAxisSpacing: 10, // Spacing between rows
                  childAspectRatio: 1, // Aspect ratio of each item (100x100)
                ),
                itemCount: survey['documents'].length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text("Pdf Viewer"),
                                      ),
                                      body: SfPdfViewer.network(
                                        '$serverURL/api/${survey['documents'][index][1]}',
                                        key: _pdfViewerKey,
                                      ),
                                    )));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.document_scanner,
                            size: 30,
                          ),
                          Text(
                            survey['documents'][index][0],
                            softWrap: true,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const Text(
            "Images",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (survey['images'] != null &&
              survey['images'] is List) // Ensure it's a List
            SizedBox(
              height: 350,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: (survey['images'] as List).map((image) {
                  // Cast explicitly to List
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeableImageGallery(
                            images: survey['images'],
                            initialIndex:
                                (survey['images'] as List).indexOf(image),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      '$serverURL/api/$image',
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
        ]),
      ),
    );
  }
}
