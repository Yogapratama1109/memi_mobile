import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../api/asset_detail_api.dart';
import '../../api/list_status.dart';
import 'package:toastification/toastification.dart';

class AssetDetailPage extends StatefulWidget {
  final String assetId;

  const AssetDetailPage({super.key, required this.assetId});

  @override
  _AssetDetailPageState createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  bool isLoading = true;

  Map<String, dynamic>? detail;
  final ApiAssetDetail apiAssetDetail = ApiAssetDetail();

  String nameMaintenance = "";
  String maintenanceCategory = "";
  String descriptionMaintenance = "";
  String maintenanceDate = "";
  String maintenanceBy = "";
  String maintenanceStatus = "";
  String dateCompleted = "";
  String serviceCategory = "";
  String replacementSpareport = "";
  String spareportComponent = "";
  String maintenanceCost = "";

  List<String> spareportComponentList = [];
  List<String> statusOptions = [];

  late TextEditingController _dateCompletedController;

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

  @override
  void initState() {
    super.initState();
    _dateCompletedController = TextEditingController(text: "-");
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
    _fetchAssetDetail();
    loadStatusOptions();
  }

  Future<void> loadStatusOptions() async {
    List<Map<String, dynamic>> statuses = await ApiListStatus.fetchStatusList();

    setState(() {
      // Simpan hanya label (tanpa ID) dalam bentuk list ["approved", "rejected"]
      statusOptions = statuses.map((item) => item['label'].toString()).toList();

      // Jika maintenanceStatus tidak cocok dengan opsi, gunakan yang pertama sebagai default
      if (!statusOptions.contains(maintenanceStatus)) {
        maintenanceStatus = statusOptions.isNotEmpty ? statusOptions.first : "";
      }
    });
  }

  Future<void> _fetchAssetDetail() async {
    try {
      final String assetId = widget.assetId.toString(); // Konversi ke string

      final response = await apiAssetDetail.getAssetDetail(assetId);

      if (response.containsKey('data')) {
        setState(() {
          detail = response['data'];
          nameMaintenance = detail?['maintenance_name']?.toString() ?? "-";
          maintenanceCategory =
              detail?['maintenance_category']?.toString() ?? "-";
          descriptionMaintenance =
              detail?['maintenance_desc']?.toString() ?? "-";
          maintenanceDate =
              detail?['maintenance_date'] != null
                  ? DateFormat("d MMM yyyy").format(
                    DateTime.parse(detail!['maintenance_date'].toString()),
                  )
                  : "-";
          maintenanceBy = detail?['name']?.toString() ?? "-";
          maintenanceStatus = detail?['status']?.toString() ?? "-";
          dateCompleted = detail?['date_completed']?.toString() ?? "-";
          serviceCategory = detail?['service_category']?.toString() ?? "-";
          replacementSpareport =
              detail?['replacement_sparepart']?.toString() ?? "No";
          spareportComponent =
              detail?['replacement_sparepart_desc']?.toString() ?? "-";
          maintenanceCost =
              detail?['cost']?.toString() ??
              "0"; // Convert to string explicitly

          spareportComponentList =
              spareportComponent != "-" && spareportComponent.isNotEmpty
                  ? spareportComponent.split(',').map((e) => e.trim()).toList()
                  : ["-"]; // Default to ["-"] if empty
          isLoading = false;

          if (dateCompleted != "-") {
            DateTime parsedDate = DateTime.parse(dateCompleted);
            _dateCompletedController.text = DateFormat(
              "dd/MM/yyyy",
            ).format(parsedDate);
          }
        });

        // debugPrint("Asset Detail: $detail");
      } else {
        throw Exception("Invalid API response: 'data' key not found");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching asset details: $error");
    }
  }

  Future<void> _selectDateCompleted() async {
    DateTime initialDate =
        (dateCompleted != "-") ? DateTime.parse(dateCompleted) : DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateCompleted = DateFormat("yyyy-MM-dd HH:mm:ss").format(pickedDate);
        _dateCompletedController.text = DateFormat(
          "dd/MM/yyyy",
        ).format(pickedDate);
      });
    }
  }

  Future<void> updateAsset() async {
    try {
      // Show "Updating..." toast first
      toastification.show(
        context: context,
        title: Text("Updating..."),
        style: ToastificationStyle.fillColored,
        description: Text("Please wait while updating the asset."),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(
          seconds: 2,
        ), // Toast stays for 2 seconds
        alignment: Alignment.topRight,
      );

      // Delay execution for 1 second
      await Future.delayed(const Duration(seconds: 1));

      // Ensure cost is an integer value
      String cleanCost = maintenanceCost.replaceAll(RegExp(r'[^0-9]'), '');
      cleanCost =
          cleanCost.isNotEmpty ? cleanCost : "0"; // Default to 0 if empty

      // Prepare payload for API request
      Map<String, dynamic> payload = {
        "maintenance_status": maintenanceStatus,
        "date_completed": dateCompleted != "-" ? dateCompleted : null,
        "replacement_sparepart": replacementSpareport,
        "replacement_sparepart_desc": spareportComponent,
        "cost": cleanCost,
      };

      debugPrint("Sending payload: $payload");

      final response = await apiAssetDetail.updateAssetDetail(
        widget.assetId,
        payload,
      );

      if (response.containsKey('status') && response['status'] == 'success') {
        _showSuccessAlert("Update successful");
        Navigator.pop(
          context,
          true,
        ); // Return to the previous page with success status
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
              'Asset Maintenance Detail',
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
                        "Name Maintenance",
                        nameMaintenance,
                        true,
                      ),
                      _buildTextField(
                        "Maintenance Category",
                        maintenanceCategory,
                        true,
                      ),
                      _buildTextField(
                        "Description Maintenance",
                        descriptionMaintenance,
                        true,
                      ),
                      _buildTextField(
                        "Maintenance Date",
                        maintenanceDate,
                        true,
                      ),
                      _buildTextField("Maintenance by", maintenanceBy, true),
                      _buildDropdownFieldCustom(
                        "Maintenance Status",
                        maintenanceStatus,
                        statusOptions,
                      ),
                      _buildDateField(
                        "Date Completed",
                        _dateCompletedController,
                        _selectDateCompleted,
                      ),
                      _buildTextField(
                        "Service Category",
                        serviceCategory,
                        true,
                      ),
                      _buildDropdownField(
                        "Replacement Spareport",
                        replacementSpareport,
                        ["Yes", "No"],
                      ),
                      if (replacementSpareport != "No")
                        _buildDropdownField(
                          "Select Spareport Component",
                          spareportComponentList.isNotEmpty
                              ? spareportComponentList.first
                              : "-",
                          spareportComponentList, // Pass the list as dropdown items
                        ),
                      _buildNumericTextField(
                        "Maintenance Cost",
                        maintenanceCost,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            updateAsset();
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

  Widget _buildNumericTextField(String label, String value) {
    final TextEditingController controller = TextEditingController(
      text:
          value.isNotEmpty
              ? "Rp. ${NumberFormat("#,###", "id_ID").format(int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)}"
              : "Rp. 0",
    );

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
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only numbers
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (input) {
              String cleanText = input.replaceAll(RegExp(r'[^0-9]'), '');
              if (cleanText.isEmpty) {
                controller.text = "Rp. 0";
              } else {
                int value = int.parse(cleanText);
                controller.text =
                    "Rp. ${NumberFormat("#,###", "id_ID").format(value)}";
              }
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, bool isDisabled) {
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
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDisabled ? Colors.grey[200] : Colors.white,
            ),
            enabled: !isDisabled,
          ),
        ],
      ),
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
                if (label == "Maintenance Status") {
                  maintenanceStatus = newValue!;
                } else if (label == "Replacement Spareport") {
                  replacementSpareport = newValue!;
                } else if (label == "Select Spareport Component") {
                  spareportComponent = newValue!;
                }
              });
            },
            items:
                options
                    .toSet()
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

  Widget _buildDropdownFieldCustom(
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
                if (label == "Maintenance Status") {
                  maintenanceStatus = newValue!;
                }
              });
            },
            items:
                options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option, // Langsung gunakan label sebagai value
                    child: Text(option), // Tampilkan label
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
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
          TextFormField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFFCBA851),
              ),
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}