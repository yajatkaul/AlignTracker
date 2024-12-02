import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Adminsiteview extends StatefulWidget {
  const Adminsiteview({super.key});

  @override
  State<Adminsiteview> createState() => _AdminsiteviewState();
}

class _AdminsiteviewState extends State<Adminsiteview> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<dynamic> sites = [];

  final ScrollController _scrollController = ScrollController();

  Future<void> _getSites() async {
    if (isLoading || !hasMore) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    String url =
        '$serverURL/api/tracking/admin/trackingData?page=$currentPage&limit=14';

    if (filterSitename != null && filterSitename!.isNotEmpty) {
      url += '&siteName=$filterSitename';
    }
    if (filterName != null && filterName!.isNotEmpty) {
      url += '&name=$filterName';
    }
    if (filterDateStart != null) {
      url += '&dateStart=${filterDateStart!.toIso8601String()}';
    }
    if (filterDateEnd != null) {
      url += '&dateEnd=${filterDateEnd!.toIso8601String()}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          sites.addAll(data['sites']);
          hasMore = data['hasMore'];
          currentPage++;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getSites();

    siteNameController.text = filterSitename ?? '';
    employeeNameController.text = filterName ?? '';

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _getSites();
        }
      }
    });
  }

  void clearFilters() {
    siteNameController.text = "";
    employeeNameController.text = "";
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        currentPage = 1;
        hasMore = true;
        sites = [];
      });
    }
    await _getSites();
  }

  @override
  void dispose() {
    siteNameController.dispose();
    employeeNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //filters
  TextEditingController siteNameController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  String? filterName, filterSitename;
  DateTime? filterDateStart, filterDateEnd;
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finished Sites"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        // ignore: sized_box_for_whitespace
                        return Container(
                          height: 450,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Filters",
                                  style: TextStyle(fontSize: 18),
                                ),
                                TextField(
                                  controller: siteNameController,
                                  onChanged: (value) {
                                    setModalState(() {
                                      filterSitename = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Site Name",
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: employeeNameController,
                                  onChanged: (value) {
                                    setModalState(() {
                                      filterName = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Employee Name",
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );

                                      if (pickedDate != null) {
                                        setModalState(() {
                                          filterDateStart = pickedDate;
                                        });
                                      }
                                    },
                                    style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20)))),
                                    child: Text(filterDateStart == null
                                        ? "Date"
                                        : "Start Date: ${filterDateStart!.day}/${filterDateStart!.month}/${filterDateStart!.year}"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );

                                      if (pickedDate != null) {
                                        setModalState(() {
                                          filterDateEnd = pickedDate;
                                        });
                                      }
                                    },
                                    style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20)))),
                                    child: Text(filterDateEnd == null
                                        ? "Date"
                                        : "End Date: ${filterDateEnd!.day}/${filterDateEnd!.month}/${filterDateEnd!.year}"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          currentPage = 1;
                                          hasMore = true;
                                          sites = [];
                                          _getSites();

                                          Navigator.pop(context, 1);
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.search),
                                            Text("Search")
                                          ],
                                        )),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          setModalState(() {
                                            filterDateEnd = null;
                                            filterDateStart = null;
                                            filterName = null;
                                            filterSitename = null;
                                            currentPage = 1;
                                            hasMore = true;
                                            sites = [];
                                          });

                                          clearFilters();
                                          _getSites();
                                        },
                                        child: const Icon(Icons.refresh))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
                ;
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                size: 35,
              ))
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: sites.map((site) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)))),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 10,
                            height: 70,
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              site['siteName'] ?? 'No Title',
                              softWrap: true,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Text(
                            site['employeeName'] ?? "No Name",
                            softWrap: true,
                          ),
                          const Icon(Icons.check)
                        ],
                      ),
                      Text(site['timing'],
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
