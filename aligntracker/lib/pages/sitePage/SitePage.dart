import 'dart:async';
import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/sitePage/CompleteSite.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher_string.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final siteID = prefs.getString('siteID');

  if (siteID != null) {
    _trackLocation(siteID);
  }

  // service.on('setSiteID').listen((data) {
  //   if (data != null && data['siteID'] != null) {
  //     _trackLocation(data['siteID']);
  //   }
  // });

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background service stopped");
  });

  //Debugging
  // Timer.periodic(const Duration(seconds: 1), (timer) {
  //   print("Service running at ${DateTime.now().second}");
  // });
}

// Move onIosBackground to a top-level function
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final siteID = prefs.getString('siteID');

  if (siteID != null) {
    _trackLocation(siteID);
  }

  // service.on('setSiteID').listen((data) {
  //   if (data != null && data['siteID'] != null) {
  //     _trackLocation(data['siteID']);
  //   }
  // });

  return true;
}

// Make _trackLocation a top-level function as well
Future<void> _trackLocation(String siteID) async {
  print("Called");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final sessionCookie = prefs.getString('session_cookie');

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    //distanceFilter: 100,
  );

  //1st time
  try {
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    print("Sending location: ${position.latitude}, ${position.longitude}");

    // Send location to the server
    await http.post(
      Uri.parse('$serverURL/api/tracking/trackSite'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode(<String, String>{
        'siteID': siteID,
        'latitude': '${position.latitude}',
        'longitude': '${position.longitude}',
      }),
    );
  } catch (e) {
    print("Error while fetching location: $e");
  }

  //Timer
  Timer.periodic(const Duration(hours: 1), (timer) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);

      print("Sending location: ${position.latitude}, ${position.longitude}");

      // Send location to the server
      await http.post(
        Uri.parse('$serverURL/api/tracking/trackSite'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': sessionCookie!,
        },
        body: jsonEncode(<String, String>{
          'siteID': siteID,
          'latitude': '${position.latitude}',
          'longitude': '${position.longitude}',
        }),
      );
    } catch (e) {
      print("Error while fetching location: $e");
    }
  });

  // Listen for changes in location services status
  Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
    if (status == ServiceStatus.enabled) {
      http.post(
        Uri.parse('$serverURL/api/tracking/locationStatusChecker'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': sessionCookie!,
        },
        body: jsonEncode(<String, String>{
          'siteID': siteID,
          'status': "Working",
        }),
      );
    } else {
      http.post(
        Uri.parse('$serverURL/api/tracking/locationStatusChecker'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': sessionCookie!,
        },
        body: jsonEncode(<String, String>{
          'siteID': siteID,
          'status': "Stopped",
        }),
      );
    }
  });

  // For constant updates
  // Geolocator.getPositionStream(locationSettings: locationSettings)
  //     .listen((Position position) {
  //   print(position.latitude);
  //   http.post(
  //     Uri.parse('$serverURL/api/tracking/trackSite'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Cookie': sessionCookie!,
  //     },
  //     body: jsonEncode(<String, String>{
  //       'siteID': siteID,
  //       'latitude': '${position.latitude}',
  //       'longitude': '${position.longitude}',
  //     }),
  //   );
  // });
}

class SitePage extends StatefulWidget {
  final Map<String, dynamic> site;

  const SitePage({super.key, required this.site});

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  bool? started;
  bool? finished;

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        //autoStartOnBoot: true,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('siteID', widget.site['_id']);

    await service.startService();

    // service.invoke('setSiteID', {"siteID": widget.site['_id']});
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
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If permissions are denied, show a message and return
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
                'Please enable location permissions to start tracking.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Step 2: Check if location services are enabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // Show a dialog to prompt the user to enable location services
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Location Services'),
          content:
              const Text('Please turn on location services to start tracking.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
              ),
            ),
          ],
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('siteID') != null) {
      print(prefs.getString('siteID'));
      showToast(context, "You have already started a site", false);
      return;
    }

    await initializeService();
    setState(() {
      started = true;
      finished = false;
    });
  }

  CameraPosition get _initialCameraPosition {
    return CameraPosition(
      target: LatLng(
        double.parse(widget.site['latitude']),
        double.parse(widget.site['longitude']),
      ),
      zoom: 11.5,
    );
  }

  Future<void> _googlemaps() async {
    String googleMaps =
        "https://www.google.com/maps/search/?api=1&query=${widget.site['latitude']},${widget.site['longitude']}";

    await launchUrlString(googleMaps);
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        markers: {
                          Marker(
                              markerId: const MarkerId("SiteLocation"),
                              position: LatLng(
                                  double.parse(widget.site['latitude']),
                                  double.parse(widget.site['longitude'])))
                        },
                      ),
                    )),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
                  onPressed: _googlemaps,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                            height: 70,
                          ),
                          Text(
                            "Open in Google Maps",
                            softWrap: true,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  "Time: ${widget.site['timing']}",
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
            if (started == null && finished == null)
              const Center(
                child: SizedBox(
                    height: 50, width: 50, child: CircularProgressIndicator()),
              ),
            if (started != null && started == false)
              SlideAction(
                text: "Start",
                onSubmit: _startTracking,
              ),
            if (finished != null &&
                started != null &&
                finished == false &&
                started == true)
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
