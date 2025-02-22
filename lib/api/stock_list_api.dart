import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiStockOpname {
  static const String _baseUrl = 'http://203.175.11.163/api';

  Future<List<Map<String, String>>> getStockOpnameList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('X-USER-MEMO');

      if (userId == null) {
        throw Exception('User ID not found in local storage');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/stock-opname/user/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        List<dynamic> data = jsonResponse['data'];

        return data.map((item) {
          return {
            "asset_id": item["asset_id"]?.toString() ?? "Unknown",
            "asset_name": item["asset_name"]?.toString() ?? "Unknown",
            "category": item["category"]?.toString() ?? "Unknown",
            "subcategory": item["subcategory"]?.toString() ?? "Unknown",
            "created_at": item["created_at"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        throw Exception('Failed to load stock opname data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
