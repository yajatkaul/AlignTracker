import 'package:aligntracker/env.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SnagDetails extends StatefulWidget {
  final String topic, issue;
  final List<dynamic> images;
  const SnagDetails(
      {super.key,
      required this.topic,
      required this.issue,
      required this.images});

  @override
  State<SnagDetails> createState() => _SnagDetailsState();
}

class _SnagDetailsState extends State<SnagDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Topic",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(widget.topic),
            const SizedBox(height: 10),
            const Text(
              "Issue",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(widget.issue),
            const SizedBox(height: 10),
            const Text(
              "Images",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                children: widget.images.map((image) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeableImageGallery(
                            images: widget.images,
                            initialIndex: widget.images.indexOf(image),
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
          ],
        ),
      ),
    );
  }
}

class SwipeableImageGallery extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const SwipeableImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<SwipeableImageGallery> createState() => _SwipeableImageGalleryState();
}

class _SwipeableImageGalleryState extends State<SwipeableImageGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Gallery"),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: PhotoView(
              imageProvider:
                  NetworkImage('$serverURL/api/${widget.images[index]}'),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black, // Black background for a better experience
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          );
        },
      ),
    );
  }
}