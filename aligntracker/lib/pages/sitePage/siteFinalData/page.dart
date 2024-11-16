import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class FinalSitePage extends StatefulWidget {
  final String siteId;
  const FinalSitePage({super.key, required this.siteId});

  @override
  State<FinalSitePage> createState() => _FinalSitePageState();
}

class _FinalSitePageState extends State<FinalSitePage> {
  bool loaded = false;
  List<dynamic> siteImages = [];
  List<dynamic> locations = [];
  String? selfi;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  Future<void> _getSites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/tracking/getTracking?siteID=${widget.siteId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          final responseBody = jsonDecode(response.body);
          loaded = true;
          siteImages = responseBody['siteImages'];
          selfi = responseBody['selfi'];
          locations = responseBody['locations'];
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
        title: const Text("Overview"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Text(
              "Site Images",
              style: TextStyle(fontSize: 20),
            ),
            Wrap(
              children: siteImages.map((image) {
                return GestureDetector(
                  onTap: () => _showImageDialog(image),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SizedBox(
                        height: 130,
                        width: 130,
                        child: Image(
                          image: NetworkImage('$serverURL/api/$image'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Text(
              "Employee Image",
              style: TextStyle(fontSize: 20),
            ),
            if (selfi != null)
              Wrap(
                children: [
                  GestureDetector(
                    onTap: () => _showImageDialog(selfi!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: Image(
                          image: NetworkImage('$serverURL/api/$selfi'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const Text(
              "Locations",
              style: TextStyle(fontSize: 20),
            ),
            if (locations.isNotEmpty)
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    markers: markers,
                    polylines: polylines,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.network(
              '$serverURL/api/$imageUrl',
              fit: BoxFit.cover,
              width: 600,
              height: 600,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
