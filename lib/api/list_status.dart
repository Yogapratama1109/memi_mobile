import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiListStatus {
  static const String _baseUrl = "http://203.175.11.163/api";

  static Future<List<Map<String, dynamic>>> fetchStatusList() async {
    final String apiUrl = "$_baseUrl/list-status";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Ubah format agar sesuai dengan ID dan Label
        return data.map((item) {
          return {
            "id": item['status_id'], // Ambil ID dari API
            "label": item['status'], // Ambil Label dari API
          };
        }).toList();
      } else {
        throw Exception("Failed to load statuses");
      }
    } catch (e) {
      print("Error fetching statuses: $e");
      return [];
    }
  }
}
