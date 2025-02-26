import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  final String baseUrl = "http://203.175.11.163/api"; // Ganti dengan URL API Anda

  Future<Map<String, dynamic>> addAudit({
    required int assetId,
    String? auditName,
    String? auditCondition,
    String? auditDate,
    String? note,
  }) async {
    final url = Uri.parse("$baseUrl/audit/add");
    SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('X-USER-MEMO');

    final Map<String, dynamic> body = {
      "asset_id": assetId,
      "audit_name": auditName,
      "audit_condition": auditCondition,
      "audit_date": auditDate,
      "note": note,
      "created_by": userId,
    };

    body.removeWhere((key, value) => value == null); // Hapus nilai null dari body

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": true,
          "message": jsonDecode(response.body)["message"] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return {
        "error": true,
        "message": "Failed to connect to the server",
      };
    }
  }
}
