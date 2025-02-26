import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audit_submit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailAudit extends StatefulWidget {
  final String id;

  const DetailAudit({Key? key, required this.id}) : super(key: key);

  @override
  _DetailAuditState createState() => _DetailAuditState();
}

class _DetailAuditState extends State<DetailAudit> {
  bool isLoading = true;
  Map<String, dynamic>? detail;

  @override
  void initState() {
    super.initState();
    debugPrint("ID: ${widget.id}");
    fetchAssetDetail();
  }

  Future<void> fetchAssetDetail() async {
    final String assetId = widget.id.toString();
    debugPrint(assetId);

    final response = await http.get(
      Uri.parse('http://203.175.11.163/api/assets/$assetId'),
    );

    if (response.statusCode == 200) {
      debugPrint(json.encode(json.decode(response.body)));

      setState(() {
        final decodedResponse = json.decode(response.body);
        debugPrint(decodedResponse.toString());

        if (decodedResponse["status"] == "success") {
          detail = decodedResponse["data"]; // Ambil bagian "data" saja
        } else {
          detail = {}; // Pastikan tidak null jika status bukan success
        }

        Timer(const Duration(seconds: 1), () {
          setState(() {
            isLoading = false;
          });
        });
      });
    } else {
      throw Exception('Failed to load asset details');
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
              'Asset Audit Detail',
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
              : SingleChildScrollView(
                // Agar bisa di-scroll
                physics: const BouncingScrollPhysics(), // Efek scroll smooth
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Memiontec Indonesia",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.laptop, size: 40),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail?["asset_name"] ?? "-",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoText(
                                  "Created Date",
                                  detail?["created_at"] ?? "-",
                                ),
                                _infoText("Created By", detail?["createName"] ?? "-"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Table Data
                      Table(
                        border: TableBorder.all(color: Colors.black),
                        columnWidths: const {0: FractionColumnWidth(0.4)},
                        children: [
                          _tableRow("Asset ID", detail?["asset_id"] ?? "-"),
                          _tableRow("Category", detail?["category"] ?? "-"),
                          _tableRow(
                            "Sub Category",
                            detail?["sub_category"] ?? "-",
                          ),
                          _tableRow(
                            "Manufacture",
                            detail?["manufacture"] ?? "-",
                          ),
                          _tableRow("Model", detail?["model"] ?? "-"),
                          _tableRow(
                            "Serial Number",
                            detail?["serial_number"] ?? "-",
                          ),
                          _tableRow(
                            "Part Number",
                            detail?["part_number"] ?? "-",
                          ),
                          _tableRow("Location", detail?["location"] ?? "-"),
                          _tableRow("Position", detail?["position"] ?? "-"),
                          _tableRow("Condition", detail?["condition"] ?? "-"),
                          _tableRow(
                            "Purchase Date",
                            detail?["purchase_date"] ?? "-",
                          ),
                          _tableRow("Supplier", detail?["supplier"] ?? "-"),
                          _tableRow("PO Number", detail?["po_number"] ?? "-"),
                          _tableRow("Price", detail?["price"] ?? "-"),
                          _tableRow(
                            "First Date Received",
                            detail?["first_date_received"] ?? "-",
                          ),
                          _tableRow(
                            "Received By",
                            detail?["received_by"] ?? "-",
                          ),
                          _tableRow(
                            "Last Modified",
                            detail?["last_modified"] ?? "-",
                          ),
                          _tableRow("Event", detail?["event"] ?? "-"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Specification
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          // ignore: prefer_interpolation_to_compose_strings
                          "Specification:\n" +
                              (detail?["specification"] ?? "-"),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Audit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FormPage(id: "${widget.id}"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCBA851),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Audit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// Widget untuk membuat teks berpasangan
Widget _infoText(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      Text(value, style: const TextStyle(fontSize: 14)),
    ],
  );
}

// Widget untuk membuat tabel dengan dua kolom
TableRow _tableRow(String key, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
    ],
  );
}
