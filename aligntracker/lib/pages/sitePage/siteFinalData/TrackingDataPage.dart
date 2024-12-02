import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Trackingdatapage extends StatefulWidget {
  final String siteId;
  const Trackingdatapage({super.key, required this.siteId});

  @override
  State<Trackingdatapage> createState() => _TrackingdatapageState();
}

class _TrackingdatapageState extends State<Trackingdatapage> {
  bool loaded = false;
  List<dynamic> siteImages = [];
  List<dynamic> locations = [];
  List<dynamic> locationStatus = [];
  String? selfi;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  Future<void> _getSites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse(
          '$serverURL/api/tracking/getspecificTracking?siteID=${widget.siteId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          print(response.body);
          final responseBody = jsonDecode(response.body);
          loaded = true;
          siteImages = responseBody['siteImages'];
          selfi = responseBody['selfi'];
          locations = responseBody['locations'];
          locationStatus = responseBody['locationStatus'];
        });
        _generateMarkers();
      }
    }
  }

  void _generateMarkers() {
    markers = locations.asMap().entries.map((entry) {
      int index = entry.key;
      List<dynamic> location = entry.value;
      return Marker(
        markerId: MarkerId(index.toString()),
        position: LatLng(
          double.parse(location[0]),
          double.parse(location[1]),
        ),
        infoWindow: InfoWindow(
          title: location[2],
          snippet: 'Lat: ${location[0]}, Lng: ${location[1]}',
        ),
      );
    }).toSet();

    // Generate Polyline from locations
    List<LatLng> polylineCoordinates = locations.map((location) {
      return LatLng(
        double.parse(location[0]),
        double.parse(location[1]),
      );
    }).toList();

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        visible: true,
        points: polylineCoordinates,
        color: Colors.blue,
        width: 4,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getSites();
  }

  CameraPosition get _initialCameraPosition {
    return CameraPosition(
      target: LatLng(
        double.parse(locations[0][0]),
        double.parse(locations[0][1]),
      ),
      zoom: 11.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Text(
              "Locations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (locations.isNotEmpty)
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: GestureDetector(
                    onVerticalDragUpdate:
                        (_) {}, // Prevents vertical drag gestures.
                    child: GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      markers: markers,
                      polylines: polylines,
                      gestureRecognizers: Set()
                        ..add(Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        )), // Enables map gestures.
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Location Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (locationStatus.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locationStatus.length,
                itemBuilder: (context, index) {
                  final status = locationStatus[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Icon(
                        status[0] == 'Working'
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        color:
                            status[0] == 'Working' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        "Status: ${status[0]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status[0] == 'Working'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      subtitle: Text("Time: ${status[1]}"),
                    ),
                  );
                },
              )
            else
              const Text(
                "No location status data available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
