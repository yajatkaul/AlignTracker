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

class SnagAdd extends StatefulWidget {
  final String siteID;
  const SnagAdd({super.key, required this.siteID});

  @override
  State<SnagAdd> createState() => _SnagAddState();
}

class _SnagAddState extends State<SnagAdd> {
  List<File> siteImages = [];
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

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
        Uri.parse('$serverURL/api/data/createSnag?siteId=${widget.siteID}');

    var request = http.MultipartRequest('POST', url);

    request.headers['Cookie'] = sessionCookie!;

    for (var image in siteImages) {
      final mimeTypeData =
          lookupMimeType(image!.path, headerBytes: [0xFF, 0xD8])?.split('/');
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

    request.fields['topic'] = _topicController.text;
    request.fields['issue'] = _issueController.text;

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
    _issueController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> uploadSnag(BuildContext context) async {
    if (_issueController.text == "" ||
        _topicController.text == "" ||
        siteImages.isEmpty) {
      showToast(context, "Fill all the fileds", false);
      return;
    }

    await uploadImages();
    if (mounted) {
      Navigator.pop(context, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a snag"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Topic",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Snag Topic",
                )),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Issue",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: _issueController,
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
              onPressed: () {
                uploadSnag(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wrap_text,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                        height: 70,
                      ),
                      Text(
                        "Upload Snag",
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
