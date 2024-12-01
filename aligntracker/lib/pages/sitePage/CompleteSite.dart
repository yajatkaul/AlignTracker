import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/planPage/SnagAdd.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Completesite extends StatefulWidget {
  final String siteID;
  const Completesite({super.key, required this.siteID});

  @override
  State<Completesite> createState() => _CompletesiteState();
}

class _CompletesiteState extends State<Completesite> {
  File? yourImage;
  List<File> siteImages = [];
  String? remarks;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickYourImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        yourImage = File(pickedFile.path);
      });
    }
  }

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
    final Uri url = Uri.parse(
        '$serverURL/api/tracking/completeSite?siteID=${widget.siteID}');

    var request = http.MultipartRequest('POST', url);

    if (yourImage != null) {
      final mimeTypeData =
          lookupMimeType(yourImage!.path, headerBytes: [0xFF, 0xD8])
              ?.split('/');
      var pic = await http.MultipartFile.fromPath(
        'selfi',
        yourImage!.path,
        filename: basename(yourImage!.path),
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      );
      request.files.add(pic);
      request.headers['Cookie'] = sessionCookie!;
    }

    for (var image in siteImages) {
      final mimeTypeData =
          lookupMimeType(yourImage!.path, headerBytes: [0xFF, 0xD8])
              ?.split('/');
      var pic = await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: basename(image.path),
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      );
      request.files.add(pic);
    }

    remarks = _controller.text;
    if (remarks != null) {
      request.fields['remarks'] = remarks!;
    }

    try {
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('siteID');
        print('Images uploaded successfully!');
      } else {
        print('Failed to upload images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> uploadProcess() async {
      if (yourImage == null || siteImages == []) {
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
        title: const Text("Site Completion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Your Image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (yourImage != null)
              Wrap(children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.file(yourImage!,
                      height: 100, width: 100, fit: BoxFit.cover),
                ),
              ]),
            ElevatedButton(
              onPressed: pickYourImage,
              child: const Text("Capture Your Image"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Site Images",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
            const Text(
              "Remarks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
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
            ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SnagAdd(
                              siteID: widget.siteID,
                            )));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                        height: 70,
                      ),
                      Text(
                        "Snags Update",
                        softWrap: true,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Spacer(),
            SlideAction(
              text: "Stop",
              onSubmit: uploadProcess,
            ),
          ],
        ),
      ),
    );
  }
}
