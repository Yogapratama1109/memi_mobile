import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAssetList {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Map<String, String>>> getMaintenanceList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('X-USER-MEMO');

      if (userId == null) {
        throw Exception('User ID not found in local storage');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/assets/user/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        List<dynamic> data = jsonResponse['data'];

        return data
            .take(3)
            .map(
              (item) => {
                "asset_id": item["asset_id"].toString(),
                "asset_name": (item["asset_name"] ?? "Unknown").toString(),
                "category": (item["category"] ?? "Unknown").toString(),
                "subcategory": (item["subcategory"] ?? "Unknown").toString(),
                "purchase_date":
                    (item["purchase_date"] ?? "Unknown").toString(),
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load maintenance data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
