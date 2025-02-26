import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:toastification/toastification.dart';
import '../../api/audit_api.dart';

void main() {
  runApp(MaterialApp(home: FormPage(id: "default_id")));
}

class FormPage extends StatefulWidget {
  final String id;

  FormPage({required this.id});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  File? _file;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String condition = 'Good'; // Default value

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            value: selectedValue,
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

  void submitAudit() async {
    if (_nameController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Name and Date are required")));
      return;
    }

    final apiService = ApiService();
    final response = await apiService.addAudit(
      assetId: int.tryParse(widget.id) ?? 0,
      auditName: _nameController.text,
      auditCondition: condition,
      auditDate:
          "${_dateController.text} 00:00:00", // Default time to avoid error
      note: _noteController.text,
    );

    debugPrint("==================");
    debugPrint(response.toString());
    debugPrint("==================");

    if (response.containsKey("message") &&
        response["message"] == "Asset audit added successfully") {
      _showSuccessAlert("Add Audit successful");
      Navigator.pop(context, true);
    } else {
      throw Exception(
        response['errors']?['audit_by']?.first ??
            "Failed to update stock opname",
      );
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
              'Add Audit',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Name Audit", _nameController),
            _buildDateField(
              "Date Audit",
              _dateController,
              () => _selectDate(context),
            ),
            _buildDropdownField("Condition", condition, [
              "Good",
              "Bad",
              "Broken",
            ]),

            // Attachment field
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text(
            //       "Attachment",
            //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            //     ),
            //     const SizedBox(height: 4),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         ElevatedButton.icon(
            //           onPressed: _pickFile,
            //           icon: const Icon(Icons.attach_file),
            //           label: const Text("Attach File"),
            //         ),
            //       ],
            //     ),
            //     if (_file != null)
            //       Text("File selected: ${_file!.path.split('/').last}"),
            //   ],
            // ),
            // const SizedBox(height: 16),
            _buildTextField("Note", _noteController),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    submitAudit, // Sebelumnya _submitForm (fungsi yang tidak ada)
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCBA851),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
