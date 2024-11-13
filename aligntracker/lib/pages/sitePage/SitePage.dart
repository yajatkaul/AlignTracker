import 'dart:async';
import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/CompleteSite.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  service.on('setSiteID').listen((data) {
    if (data != null && data['siteID'] != null) {
      _trackLocation(data['siteID']);
    }
  });

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background service stopped");
  });

  Timer.periodic(const Duration(seconds: 1), (timer) {
    print("Service running at ${DateTime.now().second}");
  });
}

// Move onIosBackground to a top-level function
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  service.on('setSiteID').listen((data) {
    if (data != null && data['siteID'] != null) {
      _trackLocation(data['siteID']);
    }
  });

  return true;
}

// Make _trackLocation a top-level function as well
Future<void> _trackLocation(String siteID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final sessionCookie = prefs.getString('session_cookie');

  final firstPos = await Geolocator.getCurrentPosition();
  print(firstPos.latitude);
  http.post(
    Uri.parse('$serverURL/api/tracking/trackSite'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Cookie': sessionCookie!,
    },
    body: jsonEncode(<String, String>{
      'siteID': siteID,
      'latitude': '${firstPos.latitude}',
      'longitude': '${firstPos.longitude}',
    }),
  );

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((Position position) {
    print(position.latitude);
    http.post(
      Uri.parse('$serverURL/api/tracking/trackSite'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie,
      },
      body: jsonEncode(<String, String>{
        'siteID': siteID,
        'latitude': '${position.latitude}',
        'longitude': '${position.longitude}',
      }),
    );
  });
}

class SitePage extends StatefulWidget {
  final Map<String, dynamic> site;

  const SitePage({super.key, required this.site});

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  bool started = true;
  bool finished = false;
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        //autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        //autoStartOnBoot: true,
      ),
    );

    service.startService();
    service.invoke('setSiteID', {"siteID": widget.site['_id']});
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  void _getSiteStatus() async {
    final response = await http.get(
      Uri.parse(
          '$serverURL/api/tracking/checkSiteStatus?siteID=${widget.site['_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          started = jsonDecode(response.body)['started'];
          finished = jsonDecode(response.body)['finished'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getSiteStatus();
  }

  Future<void> _startTracking() async {
    await initializeService();
    setState(() {
      started = true;
      finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.site['siteName'] ?? 'Site Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employee ID: ${widget.site['employeeId']}"),
            Text(
                "Location: ${widget.site['latitude']}, ${widget.site['longitude']}"),
            Text("Timing: ${widget.site['timing']}"),
            Text("Created At: ${widget.site['createdAt']}"),
            Text("Updated At: ${widget.site['updatedAt']}"),
            if (!started)
              SlideAction(
                text: "Start",
                onSubmit: _startTracking,
              ),
            if (started == true && finished == false)
              ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Completesite(
                          siteID: widget.site['_id'],
                        ),
                      ),
                    );

                    if (result == 1) {
                      stopService();
                      setState(() {
                        finished = true;
                      });
                    }
                  },
                  child: const Text("Finish Site")),
          ],
        ),
      ),
    );
  }
}
