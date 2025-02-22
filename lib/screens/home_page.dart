import 'package:flutter/material.dart';
import 'dart:async';
import 'asset/asset_list.dart';
import 'stock/stock_list.dart';
import 'asset/asset_detail.dart';
import 'stock/stock_detail.dart';
import '../api/asset_list_api.dart';
import '../api/stock_list_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  late Future<List<Map<String, String>>> maintenanceDataFuture;
  final ApiAssetList apiService = ApiAssetList();

  late Future<List<Map<String, String>>> stockOpnameDataFuture;
  final ApiStockOpname stockOpnameService = ApiStockOpname();

  @override
  void initState() {
    super.initState();
    maintenanceDataFuture = apiService.getMaintenanceList();
    stockOpnameDataFuture = stockOpnameService.getStockOpnameList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                "Asset Maintenance",
                const AssetListPage(),
              ),
              FutureBuilder<List<Map<String, String>>>(
                future: maintenanceDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Data Available",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                    return _buildAssetList(snapshot.data!);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                "Stock Opname Due",
                const StockListPage(),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<Map<String, String>>>(
                future: stockOpnameDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Data Available",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                    // print("Stock Opname Data: ${snapshot.data}");
                    return _buildAssetListStock(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            child: const Text(
              "See All",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCBA851),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetList(List<Map<String, String>> data) {
    if (data.isEmpty) {
      return const Center(
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
      );
    }

    return Column(
      children: List.generate(data.length, (index) {
        final item = data[index];
        return Column(
          children: [
            ListTile(
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
                item["asset_name"]!,
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
                    "${item["category"]} | ${item["subcategory"]}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["purchase_date"]!,
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
            ),
            const Divider(),
          ],
        );
      }),
    );
  }

  Widget _buildAssetListStock(List<Map<String, String>> data) {
    if (data.isEmpty) {
      return const Center(
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
      );
    }

    return Column(
      children: List.generate(data.length, (index) {
        final item = data[index];
        return Column(
          children: [
            ListTile(
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
                item["asset_name"]!,
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
                    "${item["category"]} | ${item["subcategory"]}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["created_at"]!,
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
                            StockDetailPage(assetId: item["asset_id"]!),
                  ),
                );
              },
            ),
            const Divider(),
          ],
        );
      }),
    );
  }
}
