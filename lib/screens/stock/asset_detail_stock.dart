import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../api/asset_detail_api.dart';

class LaptopDetailScreen extends StatefulWidget {
  final Map<String, String> laptop;

  const LaptopDetailScreen({Key? key, required this.laptop}) : super(key: key);

  @override
  _LaptopDetailScreenState createState() => _LaptopDetailScreenState();
}

class _LaptopDetailScreenState extends State<LaptopDetailScreen> {
  late String condition;
  late TextEditingController notesController;

  final ApiAssetDetail apiAssetDetail = ApiAssetDetail();

  @override
  void initState() {
    super.initState();
    condition = widget.laptop['condition'] ?? "Select Condition Here";
    notesController = TextEditingController(text: widget.laptop['notes'] ?? "");
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

  Widget _buildDropdownField(
    String label,
    String selectedValue,
    List<String> options,
  ) {
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
          DropdownButtonFormField<String>(
            value: options.contains(selectedValue) ? selectedValue : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (newValue) {
              setState(() {
                condition = newValue!;
              });
            },
            items:
                options
                    .map(
                      (option) =>
                          DropdownMenuItem(value: option, child: Text(option)),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(
    String value,
    bool isDisabled, {
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: isDisabled ? Colors.grey[200] : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 12.0,
          ),
        ),
        enabled: !isDisabled,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> updateStockOpname(
    String id,
    String assetId,
    String condition,
    String notes,
  ) async {
    try {
      notes = notes.trim();

      if (notes.isEmpty) {
        _showErrorAlert("Notes cannot be empty.");
        return;
      }

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

      Map<String, dynamic> payload = {
        "condition_item": condition,
        "note_items": notes,
      };

      debugPrint("Sending payload: $payload");

      final response = await apiAssetDetail.updateStockAsset(
        id,
        assetId,
        payload,
      );

      debugPrint("Received response: $response");

      if (response.containsKey('status') && response['status'] == 'success') {
        _showSuccessAlert("Update successful");
        Navigator.pop(context, true); // Return to the previous page with success status
      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (error) {
      debugPrint("Error updating asset: $error");
      _showErrorAlert("Update failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Update Data Opname',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFFCBA851),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField("Condition", condition, ["Good", "Bad"]),
            SizedBox(height: 16),
            Text(
              "Notes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            _buildTextArea("", false, controller: notesController),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String id = widget.laptop['id'] ?? "";
                  String assetId = widget.laptop['assetId'] ?? "";
                  updateStockOpname(
                    id,
                    assetId,
                    condition,
                    notesController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCBA851),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
