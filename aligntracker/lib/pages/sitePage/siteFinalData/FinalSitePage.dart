import 'package:flutter/material.dart';

class FinalSitePage extends StatefulWidget {
  final String siteId;
  const FinalSitePage({super.key, required this.siteId});

  @override
  State<FinalSitePage> createState() => _FinalSitePageState();
}

class _FinalSitePageState extends State<FinalSitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Data"),
      ),
    );
  }
}
