import 'dart:io';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Snagclosepage extends StatefulWidget {
  final String siteID;
  const Snagclosepage({super.key, required this.siteID});

  @override
  State<Snagclosepage> createState() => _SnagclosepageState();
}

class _SnagclosepageState extends State<Snagclosepage> {
  final TextEditingController _closeCommentController = TextEditingController();

  List<File> siteImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> pickSiteImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        siteImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> uploadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final Uri url =
        Uri.parse('$serverURL/api/data/closeSnag?siteId=${widget.siteID}');

    var request = http.MultipartRequest('POST', url);

    request.headers['Cookie'] = sessionCookie!;

    for (var image in siteImages) {
      final mimeTypeData =
          lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');
      var pic = await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: basename(image.path),
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      );
      request.files.add(pic);
    }

    request.fields['closeComment'] = _closeCommentController.text;

    try {
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Images uploaded successfully!');
      } else {
        print('Failed to upload images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  @override
  void dispose() {
    _closeCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> uploadProcess() async {
      if (siteImages == []) {
        showToast(context, "Submit all the images", false);
        return;
      }

      await uploadImages();
      if (mounted) {
        Navigator.pop(context, 1);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Close Snag"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Close Comment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: _closeCommentController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your text here...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Images",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            siteImages.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    children: siteImages.map((image) {
                      return Image.file(image,
                          height: 100, width: 100, fit: BoxFit.cover);
                    }).toList(),
                  )
                : const Text("No site images selected."),
            ElevatedButton(
              onPressed: pickSiteImages,
              child: const Text("Pick Site Images"),
            ),
            const Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
              onPressed: uploadProcess,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                        height: 70,
                      ),
                      Text(
                        "Snags Close",
                        softWrap: true,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
