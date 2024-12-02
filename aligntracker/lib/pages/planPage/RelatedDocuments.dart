import 'package:aligntracker/env.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Relateddocuments extends StatefulWidget {
  final List<dynamic> siteDocuments;
  const Relateddocuments({super.key, required this.siteDocuments});

  @override
  State<Relateddocuments> createState() => _RelateddocumentsState();
}

class _RelateddocumentsState extends State<Relateddocuments> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Determine how many columns you want (3 or 4 based on screen size)
    int columns = MediaQuery.of(context).size.width > 600 ? 4 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns, // Number of columns in the grid
            crossAxisSpacing: 10, // Spacing between columns
            mainAxisSpacing: 10, // Spacing between rows
            childAspectRatio: 1, // Aspect ratio of each item (100x100)
          ),
          itemCount: widget.siteDocuments.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 100,
              width: 100,
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
                                  '$serverURL/api/${widget.siteDocuments[index][1]}',
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
                      widget.siteDocuments[index][0],
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
    );
  }
}
