import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'asset_detail.dart';

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  bool isLoading = true;
  bool hasError = false;
  List<Map<String, String>> maintenanceData = [];

  @override
  void initState() {
    super.initState();
    fetchMaintenanceData();
  }

  Future<void> fetchMaintenanceData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('X-USER-MEMO');

      if (userId == null) {
        throw Exception('User ID not found in local storage');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/assets/user/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data =
            jsonResponse['data']; // Extract list from API response

        setState(() {
          maintenanceData =
              data
                  .map(
                    (item) => {
                      "asset_id": item["asset_id"]?.toString() ?? "Unknown",
                      "title": item["asset_name"]?.toString() ?? "Unknown",
                      "subtitle":
                          "${item["category"]?.toString() ?? "Unknown"} | ${item["subcategory"]?.toString() ?? "Unknown"}",
                      "date": item["purchase_date"]?.toString() ?? "Unknown",
                    },
                  )
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load maintenance data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFCBA851),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Asset Maintenance List',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? const Center(
                child: Text(
                  "Error fetching data. Please try again.",
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              )
              : maintenanceData.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "No Data Available",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: maintenanceData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = maintenanceData[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBA851),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment, color: Colors.white),
                    ),
                    title: Text(
                      item["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFCBA851),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["subtitle"]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["date"]!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AssetDetailPage(assetId: item["asset_id"]!),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
