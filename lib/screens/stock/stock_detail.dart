import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:toastification/toastification.dart';

class StockDetailPage extends StatefulWidget {
  final String assetId;

  const StockDetailPage({super.key, required this.assetId});

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  bool isLoading = true;
  late Map<String, String> stockOpnameData;
  late TextEditingController _auditByController;

  String auditBy = '';

  @override
  void initState() {
    super.initState();
    _auditByController = TextEditingController();
    fetchStockOpnameDetail();
  }

  Future<void> fetchStockOpnameDetail() async {
    final url = Uri.parse(
      'http://203.175.11.163/api/detail-stock-opname/${widget.assetId}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse["status"] == "success" &&
            decodedResponse["data"] != null) {
          setState(() {
            stockOpnameData = Map<String, String>.from(
              decodedResponse["data"].map(
                (key, value) =>
                    MapEntry(key.toString(), value?.toString() ?? ""),
              ),
            );

            auditBy = stockOpnameData['audit_by'] ?? '';
            _auditByController.text = auditBy;
            isLoading = false;
          });
        } else {
          throw Exception("Invalid API response");
        }
      } else {
        throw Exception("Failed to load stock opname details");
      }
    } catch (e) {
      print('Error fetching stock opname details: $e');
    }
  }

  Future<void> updateAuditBy() async {
    try {
      // Ambil nilai terbaru dari controller
      auditBy = _auditByController.text.trim();

      // Validasi input
      if (auditBy.isEmpty) {
        _showErrorAlert("Audit By field cannot be empty.");
        return;
      }

      // Show "Updating..." toast
      toastification.show(
        context: context,
        title: Text("Updating..."),
        style: ToastificationStyle.fillColored,
        description: Text("Please wait while updating the asset."),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.topRight,
      );

      await Future.delayed(const Duration(seconds: 1));

      Map<String, dynamic> payload = {"audit_by": auditBy};

      debugPrint("Sending payload: $payload");

      final url = Uri.parse(
        'http://203.175.11.163/api/update-stock/${widget.assetId}',
      );

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        fetchStockOpnameDetail();
        _showSuccessAlert("Update successful");
        Navigator.pop(context, true);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(
          responseBody['errors']?['audit_by']?.first ??
              "Failed to update stock opname",
        );
      }
    } catch (error) {
      debugPrint("Error updating audit_by: $error");
      _showErrorAlert("Update failed: $error");
    }
  }

  void _showErrorAlert(String message) {
    toastification.show(
      context: context,
      title: Text("Error"),
      style: ToastificationStyle.fillColored,
      description: Text(message),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  void _showSuccessAlert(String message) {
    toastification.show(
      context: context,
      title: Text("Success"),
      style: ToastificationStyle.fillColored,
      description: Text(message),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    bool isDisabled, {
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller ?? TextEditingController(text: value),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDisabled ? Colors.grey[200] : Colors.white,
            ),
            enabled: !isDisabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
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
              'Stock Opname Detail',
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
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        "Name",
                        stockOpnameData["name"] ?? "",
                        true,
                      ),
                      _buildTextField(
                        "Location",
                        stockOpnameData["location"] ?? "",
                        true,
                      ),
                      _buildTextField(
                        "Position",
                        stockOpnameData["position"] ?? "",
                        true,
                      ),
                      _buildTextField(
                        "Date",
                        stockOpnameData["date"] ?? "",
                        true,
                      ),
                      _buildTextField(
                        "Category",
                        stockOpnameData["category"] ?? "",
                        true,
                      ),
                      _buildTextField(
                        "Stock Opname By",
                        stockOpnameData["audit_by"] ?? "",
                        false,
                        controller: _auditByController,
                        onChanged: (value) {
                          auditBy = value; // Save input in real-time
                        },
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            updateAuditBy();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCBA851),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text(
                            'Update',
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
