import 'dart:convert';
import 'dart:io';

import 'package:aligntracker/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class SurveyAdd extends StatefulWidget {
  final String siteId;
  const SurveyAdd({super.key, required this.siteId});

  @override
  State<SurveyAdd> createState() => _SurveyAddState();
}

class _SurveyAddState extends State<SurveyAdd> {
  List<XFile> selectedImages = [];
  List<Map<String, String>> documents = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage();
      if (images != null) {
        setState(() {
          selectedImages.addAll(images);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> pickDocument(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          documents[index]['filePath'] = result.files.single.path!;
        });
      }
    } catch (e) {
      print("Error picking document: $e");
    }
  }

  void addDocumentField() {
    setState(() {
      documents.add({'name': '', 'filePath': ''});
    });
  }

  Future<void> uploadSurvey() async {
    final uri =
        Uri.parse('$serverURL/api/data/createSurvey?siteId=${widget.siteId}');
    final request = http.MultipartRequest('POST', uri);

    // Add siteId as part of the request
    request.fields['siteId'] = widget.siteId;

    // Add images as multipart files
    for (var image in selectedImages) {
      final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    // Add document names and file paths
    List<String> fileNames = [];
    for (var doc in documents) {
      if (doc['name']!.isNotEmpty && doc['filePath']!.isNotEmpty) {
        fileNames.add(doc['name']!);
        final mimeType =
            lookupMimeType(doc['filePath']!) ?? 'application/octet-stream';
        request.files.add(await http.MultipartFile.fromPath(
          'documents',
          doc['filePath']!,
          contentType: MediaType.parse(mimeType),
        ));
      }
    }
    request.fields['fileNames'] = jsonEncode(fileNames);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey uploaded successfully!')),
        );
      } else {
        print('Upload failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error uploading survey: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading survey')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Survey"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Survey Images",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: pickImages,
                child: const Text("Select Images"),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedImages
                    .map((image) => Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                "Survey Documents",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ...documents.asMap().entries.map((entry) {
                final index = entry.key;
                final doc = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          documents[index]['name'] = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Document Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => pickDocument(index),
                      child:
                          Text(doc['filePath']!.isEmpty ? "Attach" : "Change"),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: addDocumentField,
                icon: const Icon(Icons.add),
                label: const Text("Add More Documents"),
              ),
              ElevatedButton(
                onPressed: uploadSurvey,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 30),
                    SizedBox(
                      width: 10,
                      height: 70,
                    ),
                    Text(
                      "Upload Survey",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
